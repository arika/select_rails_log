# frozen_string_literal: true

require "csv"

module SelectRailsLog
  module Printer
    class TsvPrinter < BasePrinter
      DATETIME_FORMAT = "%F %T.%6N"

      COLUMNS = [
        STARTED, REQUEST_ID, "controller_action",
        HTTP_STATUS, HTTP_METHOD, PATH,
        "total_duration",
        "active_record_duration",
        "views_duration",
        "allocations"
      ].freeze

      define_options :tsv_printer do
        option :output, "--tsv [FILE]", "-t", "Output in TSV format", default: DEFAULT_OUTPUT
      end

      private

      def init_output_destination
        super
        return unless output_directory?

        raise CommandLineOptionError, "output to directory is not supported for TSV format"
      end

      def prepare
        super
        @csv = CSV.new(@output_file, col_sep: "\t", write_headers: true, headers: COLUMNS)
      end

      def print_data(_output, data)
        @csv << row(data)
      end

      def row(data)
        [
          data[STARTED].strftime(DATETIME_FORMAT),
          data[REQUEST_ID], "#{data[CONTROLLER]}##{data[ACTION]}",
          data[HTTP_STATUS], data[HTTP_METHOD], data[PATH],
          data[DURATION],
          data[PERFORMANCE][PERFORMANCE_ACTIVE_RECORD],
          data[PERFORMANCE][PERFORMANCE_VIEWS],
          data[PERFORMANCE][PERFORMANCE_ALLOCATIONS]
        ]
      end
    end
  end
end
