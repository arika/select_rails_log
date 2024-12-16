# frozen_string_literal: true

require "json"

module SelectRailsLog
  module Printer
    module DataSerializable
      include Constants

      DATETIME_FORMAT = "%FT%T.%6N%:z"

      private

      def serialize_data(data)
        serialized = data.slice(
          REQUEST_ID, CONTROLLER, ACTION,
          HTTP_STATUS, HTTP_METHOD, PATH, PARAMETERS, CLIENT,
          DURATION, PERFORMANCE
        )

        serialized[STARTED] = strftime(data[STARTED])
        serialized[COMPLETED] = strftime(data[COMPLETED])
        serialized[PID] = data[PID].to_i
        serialized[LOGS] = collect_logs(data)
        serialized
      end

      def collect_logs(data)
        logs = []

        each_log(data) do |log|
          logs << log.merge(TIME => strftime(log[TIME]))
        end

        logs
      end

      def strftime(time)
        time&.strftime(DATETIME_FORMAT)
      end
    end
  end
end
