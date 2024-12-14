# frozen_string_literal: true

module SelectRailsLog
  module Printer
    class RawPrinter < BasePrinter
      SUFFIX = ".log"
      DATETIME_FORMAT = "%FT%T.%6N"

      define_options :raw_printer do
        option :output, "--raw [PATH]", "-r", "Output in raw format", default: DEFAULT_OUTPUT
      end

      private

      def print_data(output, data)
        return print_logs(output, data) unless data.key?(RAW_LOGS)

        each_log_with_index(data) do |_log, index|
          output.puts data[RAW_LOGS][index]
        end
      end

      def print_logs(output, data)
        pid, request_id = data.values_at(PID, REQUEST_ID)
        reqid = "[#{request_id}] " if request_id
        each_log(data) do |log|
          print_log_line(output, pid, reqid, log)
        end
      end

      def print_log_line(output, pid, reqid, log)
        severity = log[SEVERITY]
        output.printf(
          "%<sev>s, [%<time>s #%<pid>d] %<severity>5s -- : %<reqid>s%<message>s\n",
          sev: severity[0],
          severity:,
          pid:,
          reqid:,
          time: log[TIME].strftime(DATETIME_FORMAT),
          message: log[MESSAGE]
        )
      end
    end
  end
end
