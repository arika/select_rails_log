# frozen_string_literal: true

module SelectRailsLog
  class Selector
    class << self
      def filter_types
        @filter_types ||= {
          request_ids: [Filter::RequestId, :pre_filter],
          controller_actions: [Filter::ControllerAction, :pre_filter],
          http_method: [Filter::HttpMethod, :pre_filter],
          http_status: [Filter::HttpStatus, :filter],
          time_range: [Filter::TimeRange, :filter],
          duration_range: [Filter::DurationRange, :filter],
          params_regexp: [Filter::ParamsRegexp, :filter],
          logs_regexp: [Filter::LogsRegexp, :filter]
        }
      end
    end

    def initialize
      @pre_filters = []
      @filters = []
    end

    def pre_filter(data)
      apply_filters(data, @pre_filters)
    end

    def run(data, &block)
      apply_filters(data, @filters, &block)
    end

    def add_filter(name, option)
      klass, type = self.class.filter_types.fetch(name)
      filter = klass.new(option)
      if type == :pre_filter
        @pre_filters << filter
      else
        @filters << filter
      end
    end

    private

    def apply_filters(data, filters)
      result = if filters.empty?
                 true
               else
                 filters.all? { |filter| filter.apply(data) }
               end

      return yield(data) if result && block_given?

      result
    end
  end
end
