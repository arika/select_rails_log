# frozen_string_literal: true

module SelectRailsLog
  module Filter
    class HttpMethodFilter < BaseFilter
      filter_type :request

      define_options :http_method_filter do
        option :http_method, "--http-method METHOD", "-M", String, "Filter by HTTP method"
      end

      def initialize(...)
        super
        @http_method = options[:http_method]&.upcase
      end

      def runnable?
        !!@http_method
      end

      def run(data)
        data[HTTP_METHOD] == @http_method
      end
    end
  end
end
