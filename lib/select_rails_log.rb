# frozen_string_literal: true

require_relative "select_rails_log/constants"
require_relative "select_rails_log/command_line_options"
require_relative "select_rails_log/extension"
require_relative "select_rails_log/filter"
require_relative "select_rails_log/printer"
require_relative "select_rails_log/selector"
require_relative "select_rails_log/runner"
require_relative "select_rails_log/scanner"
require_relative "select_rails_log/version"

module SelectRailsLog
  class Error < RuntimeError; end
  class CommandLineOptionError < Error; end

  class << self
    def run
      begin
        runner = setup_runner(ARGV)
        runner.run(Scanner.new(ARGF)) if runner&.runnable?
      rescue StopIteration, Errno::EPIPE, Interrupt
        # noop
      rescue StandardError => e
        raise e if runner&.debug?

        warn e.message
      end

      exit(runner&.success? ? 0 : 1)
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
end
