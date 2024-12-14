# frozen_string_literal: true

module SelectRailsLog
  module Filter
    class HttpStatusFilter < BaseFilter
      define_options :http_status_filter do
        option :pattern,
               "--http-statuses PATTERN", "-S", String,
               "Filter by HTTP statuses",
               "  statuses format is 'st1,st2,...', '!st1,st2,...', or 'st1,...!st2,...'.",
               "  ex: '200,302', '3,20,!201,304', or '!4,5'"
      end

      def initialize(...)
        super

        @includes = @excludes = []
        pattern = options[:pattern]
        return unless pattern

        m = /\A([,\d]+)?(?:!([,\d]+))?\z/.match(pattern)
        raise CommandLineOptionError, "invalid HTTP statuses pattern `#{pattern}`" unless m

        @includes = m[1] ? m[1].split(",") : []
        @excludes = m[2] ? m[2].split(",") : []
      end

      def runnable?
        @includes.any? || @excludes.any?
      end

      def run(data)
        http_status = data[HTTP_STATUS]
        @excludes.none? { |exc| http_status.index(exc)&.zero? } &&
          (@includes.empty? || @includes.any? { |inc| http_status.index(inc)&.zero? })
      end
    end
  end
end
