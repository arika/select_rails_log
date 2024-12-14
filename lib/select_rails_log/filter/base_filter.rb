# frozen_string_literal: true

module SelectRailsLog
  module Filter
    class BaseFilter < Extension
      include Constants

      class << self
        def filter_type(filter_type = nil)
          @filter_type ||= :line
          return @filter_type unless filter_type

          @filter_type = filter_type
        end
      end

      define_options :base_filter do
        separator ""
        separator "filter options:"
      end

      def request_filter?
        self.class.filter_type == :request
      end

      def line_filter?
        self.class.filter_type == :line
      end

      def run(obj)
        obj
      end
    end
  end
end
