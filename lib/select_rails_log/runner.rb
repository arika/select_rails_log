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
      def run(argv, argf)
        runner = setup_runner(argv)

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

      def setup_runner(argv)
        options = CommandLineOptions.new
        options.parse!(argv)

        runner = Runner.new(options)
        if runner.help?
          puts options.parser
        elsif runner.version?
          print_version
        end

        runner
      end

      def print_version
        puts "select_rails_log #{VERSION}"
        puts " - csv #{CSV::VERSION}"
        puts " - enumerable-statistics #{EnumerableStatistics::VERSION}"
        puts " - unicode_plot #{UnicodePlot::VERSION}"
        puts " - #{RUBY_ENGINE} #{RUBY_VERSION} [#{RUBY_PLATFORM}]"
      end
    end

    def initialize(...)
      super
      @count = 0
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
      $stdout.tty? && printers.none?(&:output_stdout?)
    end

    def setup
      printers, filters = %i[printer filter].map do |ext_type|
        @whole_options.extensions(ext_type).filter_map do |ext_class|
          ext = ext_class.new(@whole_options)
          ext if ext.runnable?
        end
      end
      printers << Printer::TextPrinter.new(@whole_options, fallback_output: DEFAULT_OUTPUT) if printers.empty?
      selector = Selector.new(filters)

      [selector, printers]
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
