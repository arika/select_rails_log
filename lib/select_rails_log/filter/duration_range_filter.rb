# frozen_string_literal: true

require_relative "range_pattern"

module SelectRailsLog
  module Filter
    class DurationRangeFilter < BaseFilter
      include RangePattern

      define_options :duration_range_filter do
        option :pattern,
               "--duration-range RANGE", "-D", String,
               "Filter by duration range [ms]",
               "  range format is 'ms1..ms2', 'ms1...ms2', or 'ms,delta'.",
               "  ex: '10..200', '10...200', '100,10'"
      end

      def initialize(...)
        super

        pattern = options[:pattern]
        return unless pattern

        begin
          @range = parse_range_pattern(pattern, &:to_i)
        rescue ArgumentError
          raise CommandLineOptionError, "invalid duration range pattern `#{pattern}`"
        end
      end

      def runnable?
        !!@range
      end

      def run(data)
        @range.cover?(data[DURATION])
      end
    end
  end
end
