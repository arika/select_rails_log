# frozen_string_literal: true

module SelectRailsLog
  module Filter
    module RangePattern
      private

      def parse_range_pattern(pattern)
        if /\A(?<range_begin>.*?[^.])?\.\.(?<exclude_end>\.)?(?<range_end>[^.].*)?\z/ =~ pattern
          range_begin = yield(range_begin) if range_begin
          range_end = yield(range_end) if range_end
          exclude_end = !exclude_end.nil?
          range_by_begin_end(range_begin, range_end, exclude_end)
        elsif /\A(?<base>.+),(?<delta>[^,]+)\z/ =~ pattern
          delta = delta.to_f
          base = yield(base)
          range_by_base_delta(base, delta)
        else
          raise ArgumentError
        end
      end

      def range_by_begin_end(begin_time, end_time, exclude_end)
        Range.new(begin_time, end_time, exclude_end)
      end

      def range_by_base_delta(base, delta)
        range_by_begin_end(base - delta, base + delta, true)
      end
    end
  end
end
