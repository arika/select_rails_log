# frozen_string_literal: true

module SelectRailsLog
  module Filter
    class LogsRegexpFilter < BaseFilter
      define_options :logs_regexp_filter do
        option :regexp,
               "--logs-regexp REGEXP", "-L", Regexp,
               "Filter by log messages",
               %q(  ex: '"^  Rendering .*\.json"')
      end

      def initialize(...)
        super
        @regexp = options[:regexp]
      end

      def runnable?
        !!@regexp
      end

      def run(data)
        data[LOGS].any? { |log| @regexp.match?(log[MESSAGE]) }
      end
    end
  end
end
