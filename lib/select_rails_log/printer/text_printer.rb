# frozen_string_literal: true

module SelectRailsLog
  module Printer
    class TextPrinter < BasePrinter
      SUFFIX = ".txt"
      DATETIME_FORMAT = "%FT%T.%6N"

      define_options :text_printer do
        option :output, "--text [PATH]", "Output in text format (default)", default: DEFAULT_OUTPUT
      end

      def initialize(options, standard_output, fallback_output: nil)
        @fallback_output = fallback_output
        @first = true
        super(options, standard_output)
      end

      private

      def output_option
        options[:output] || @fallback_output
      end

      def print_data(output, data)
        output.puts unless @first || output_directory?
        @first = false if @first

        print_header(output, data)
        print_body(output, data)
      end

      def print_header(output, data)
        output.puts "time: #{data[STARTED]&.strftime(DATETIME_FORMAT)} " \
                    ".. #{data[COMPLETED]&.strftime(DATETIME_FORMAT)}"
        output.puts "request_id: #{data[REQUEST_ID]}" if data[REQUEST_ID]
        output.print <<~END_OF_HEADER
          pid: #{data[PID]}
          status: #{data[HTTP_STATUS]}
          duration: #{data[DURATION]}ms
        END_OF_HEADER
      end

      def print_body(output, data)
        each_log(data) do |log|
          output.printf "[%<interval>8.3f] %<message>s\n", interval: log[INTERVAL] * 1_000, message: log[MESSAGE]
        end
      end
    end
  end
end
