# frozen_string_literal: true

module SelectRailsLog
  class Runner < Extension
    include Constants

    define_options :runner do
      separator ""
      separator "other options:"

      option :help, "--help", "-h", "Show help"
      option :version, "--version", "Show version"
      option :debug, "--debug", "Enable debug print"
    end

    class << self
      def run(argv, argf, out = $stdout)
        runner = setup_runner(argv, out)

        begin
          runner.run(Scanner.new(argf)) if runner.runnable?
        rescue StopIteration, Errno::EPIPE, Interrupt
          # noop
        end

        runner.success?
      rescue StandardError => e
        raise e if runner&.debug?

        warn e.message
        false
      end

      private

      def setup_runner(argv, out)
        options = CommandLineOptions.new
        options.parse!(argv)

        runner = Runner.new(options, out)
        if runner.help?
          out.puts options.parser
        elsif runner.version?
          print_version(out)
        end

        runner
      end

      def print_version(io)
        io.print <<~VERSION
          select_rails_log #{VERSION}
           - csv #{CSV::VERSION}
           - enumerable-statistics #{EnumerableStatistics::VERSION}
           - unicode_plot #{UnicodePlot::VERSION}
           - #{RUBY_ENGINE} #{RUBY_VERSION} [#{RUBY_PLATFORM}]
        VERSION
      end
    end

    def initialize(options, standard_output)
      super(options)
      @count = 0
      @standard_output = standard_output
    end

    def help?
      options[:help]
    end

    def version?
      options[:version]
    end

    def debug?
      options[:debug]
    end

    def success?
      help? || version? || @count.positive?
    end

    def runnable?
      !help? && !version?
    end

    def run(scanner)
      selector, printers = setup
      counter_thread = counter_thread() if output_tty?(printers)

      scanner.select(selector) do |data|
        @count += 1
        printers.each { _1.print(data) }
      end
    ensure
      counter_thread&.kill
      printers&.each(&:close)
    end

    private

    def output_tty?(printers)
      @standard_output.tty? && printers.none?(&:output_stdout?)
    end

    def setup
      filters = setup_filters
      printers = setup_printers
      printers << default_printer if printers.empty?
      selector = Selector.new(filters)

      [selector, printers]
    end

    def setup_filters
      @whole_options.extensions(:filter).filter_map do |ext_class|
        ext = ext_class.new(@whole_options)
        ext if ext.runnable?
      end
    end

    def setup_printers
      @whole_options.extensions(:printer).filter_map do |ext_class|
        ext = ext_class.new(@whole_options, @standard_output)
        ext if ext.runnable?
      end
    end

    def default_printer
      Printer::TextPrinter.new(@whole_options, @standard_output, fallback_output: DEFAULT_OUTPUT)
    end

    def counter_thread
      Thread.new do
        lambda do
          loop do
            sleep 1
            print "\r#{@count}"
          end
        ensure
          puts "\r#{@count}"
        end
      end
    end
  end
end
