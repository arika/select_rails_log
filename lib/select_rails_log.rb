# frozen_string_literal: true

require_relative "select_rails_log/version"
require_relative "select_rails_log/index"
require_relative "select_rails_log/filter"
require_relative "select_rails_log/selector"
require_relative "select_rails_log/printer"
require_relative "select_rails_log/command_line_option"

module SelectRailsLog
  class << self
    def run
      count = 0
      counter = lambda do
        loop do
          sleep 1
          print "\r#{count}"
        end
      ensure
        puts "\r#{count}"
      end

      begin
        selector = Selector.new
        printer = Printer.new
        options = CommandLineOption.parse(selector: selector, printer: printer)
        index = Index.new(ARGF)

        counter_th = Thread.new { counter.call } if $stdout.tty? && printer.output_directory

        index.select(selector) do |data|
          count += 1
          printer.print(data)
        end
      rescue Errno::EPIPE, Interrupt
        # noop
      rescue StandardError => e
        raise if options&.debug

        abort e.message
      ensure
        counter_th&.kill
      end

      exit(count.zero? ? 1 : 0)
    end
  end
end
