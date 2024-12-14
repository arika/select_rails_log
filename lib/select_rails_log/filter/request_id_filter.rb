# frozen_string_literal: true

module SelectRailsLog
  module Filter
    class RequestIdFilter < BaseFilter
      filter_type :request

      define_options :request_id_filter do
        option :request_ids, "--request-ids IDs", "-I", Array, "Filter by request-id"
      end

      def initialize(...)
        super
        @request_ids = options[:request_ids].dup
      end

      def runnable?
        @request_ids&.any?
      end

      def run(data)
        raise StopIteration if @request_ids.empty?

        !!@request_ids.delete(data[REQUEST_ID])
      end
    end
  end
end
