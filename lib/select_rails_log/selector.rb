# frozen_string_literal: true

module SelectRailsLog
  class Selector
    def initialize(filters)
      @request_filters = filters.select(&:request_filter?)
      @line_filters = filters - @request_filters
    end

    def run_request_filters(data)
      run_filters(data, @request_filters)
    end

    def run_line_filters(data, &)
      run_filters(data, @line_filters, &)
    end

    private

    def run_filters(data, filters)
      result = if filters.empty?
                 true
               else
                 filters.all? { |filter| filter.run(data) }
               end

      return yield(data) if result && block_given?

      result
    end
  end
end
