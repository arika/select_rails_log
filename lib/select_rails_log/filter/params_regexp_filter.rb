# frozen_string_literal: true

module SelectRailsLog
  module Filter
    class ParamsRegexpFilter < BaseFilter
      define_options :params_regexp_filter do
        option :regexp,
               "--params-regexp REGEXP", "-P", Regexp,
               "Filter by parameters",
               %q(  ex: '"foo"=>"ba[rz]"')
      end

      def initialize(...)
        super
        @regexp = options[:regexp]
      end

      def runnable?
        !!@regexp
      end

      def run(data)
        @regexp.match?(data[PARAMETERS])
      end
    end
  end
end
