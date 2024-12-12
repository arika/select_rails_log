# frozen_string_literal: true

module SelectRailsLog
  module Filter
    class Base
      def initialize(*); end

      def apply(obj)
        obj
      end
    end

    class RequestId < Base
      def initialize(reqids)
        super

        @request_ids = reqids
      end

      def apply(data)
        @request_ids.any?(data[:request_id])
      end
    end

    class ControllerAction < Base
      def initialize(names)
        super

        @controller_actions = controller_actions(names)
      end

      def apply(data)
        @controller_actions.any? do |controller, action|
          data[:controller] == controller &&
            (action.nil? || data[:action] == action)
        end
      end

      private

      def controller_actions(names)
        names.map do |name|
          controller, action = name.split("#", 2)
          controller = classify(controller) << "Controller" unless controller.end_with?("Controller")
          [controller, action]
        end
      end

      def classify(name)
        name.scan(%r{(?:/|[^_/]+)})
            .map { |seg| seg == "/" ? "::" : seg.capitalize }
            .join
      end
    end

    class HttpMethod < Base
      def initialize(http_method)
        super

        @http_method = http_method.upcase
      end

      def apply(data)
        data[:http_method] == @http_method
      end
    end

    class HttpStatus < Base
      def initialize(pattern)
        super

        m = /\A([,\d]+)?(?:!([,\d]+))?\z/.match(pattern)
        raise ArgumentError unless m

        @includes = m[1] ? m[1].split(",") : []
        @excludes = m[2] ? m[2].split(",") : []
      end

      def apply(data)
        http_status = data[:http_status]
        @excludes.none? { |exc| http_status.index(exc)&.zero? } &&
          (@includes.empty? || @includes.any? { |inc| http_status.index(inc)&.zero? })
      end
    end

    module RangePattern
      private

      def parse_range_pattern(pattern)
        if /\A(?<range_begin>.*?[^.])?\.\.(?<exclude_end>\.)?(?<range_end>[^.].*)?\z/ =~ pattern
          @range_begin = yield(range_begin) if range_begin
          @range_end = yield(range_end) if range_end
          @exclude_end = !exclude_end.nil?
        elsif /\A(?<range_begin>.+),(?<delta>[^,]+)\z/ =~ pattern
          delta = delta.to_f
          @range_begin = yield(range_begin)
          @range_end = @range_begin + delta
          @range_begin -= delta
          @exclude_end = true
        else
          raise ArgumentError
        end
      end

      def cover?(value)
        if @range_begin && @range_end && @exclude_end
          @range_begin <= value && value < @range_end
        elsif @range_begin && @range_end
          @range_begin <= value && value <= @range_end
        elsif @range_begin
          @range_begin <= value
        elsif @range_end && @exclude_end
          value < @range_end
        elsif @range_end
          value <= @range_end
        end
      end
    end

    class TimeRange < Base
      include RangePattern

      def initialize(pattern)
        super

        parse_range_pattern(pattern) { |time_str| Time.parse(time_str) }
      end

      def apply(data)
        cover?(data[:begin_time]) || cover?(data[:end_time])
      end
    end

    class DurationRange < Base
      include RangePattern

      def initialize(pattern)
        super

        parse_range_pattern(pattern, &:to_i)
      end

      def apply(data)
        cover?(data[:duration])
      end
    end

    class ParamsRegexp < Base
      def initialize(regexp)
        super

        @regexp = regexp
      end

      def apply(data)
        @regexp.match?(data[:parameters])
      end
    end

    class LogsRegexp < Base
      def initialize(regexp)
        super

        @regexp = regexp
      end

      def apply(data)
        data[:logs].any? { |log| @regexp.match?(log[:message]) }
      end
    end
  end
end
