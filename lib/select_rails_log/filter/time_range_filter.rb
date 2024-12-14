# frozen_string_literal: true

require_relative "range_pattern"

module SelectRailsLog
  module Filter
    class TimeRangeFilter < BaseFilter
      include RangePattern

      define_options :time_range_filter do
        option :pattern,
               "--time-range RANGE", "-T", String,
               "Filter by time range",
               "  range format is 'time1..time2', 'time1...time2', or 'time,seconds'.",
               "  ex: '2018-01-02 12:00..2018-02-01 12:00', '1/2 12:00...2/2 12:00', '3/5 12:00,30'"
      end

      def initialize(...)
        super

        pattern = options[:pattern]
        return unless pattern

        begin
          @range = parse_range_pattern(pattern) { |time_str| Time.parse(time_str) }
        rescue ArgumentError
          raise CommandLineOptionError, "invalid time range pattern `#{pattern}`"
        end
      end

      def runnable?
        !!@range
      end

      def run(data)
        return true if @range.cover?(data[STARTED]) || @range.cover?(data[COMPLETED])

        range = data[STARTED]..data[COMPLETED]
        range.cover?(@range.begin) || range.cover?(@range.end)
      end
    end
  end
end
