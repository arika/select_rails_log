# frozen_string_literal: true

require "enumerable/statistics"

module SelectRailsLog
  module Printer
    class StatisticsPrinter < BasePrinter
      STAT_TOTAL_DURATION = "Total"

      DEFAULT_TARGETS = [
        STAT_TOTAL_DURATION,
        PERFORMANCE_ACTIVE_RECORD,
        PERFORMANCE_VIEWS,
        PERFORMANCE_ALLOCATIONS
      ].freeze

      PERCENTILES = [25, 50, 75, 90, 95, 99].freeze

      define_options :statistics_printer do
        option :output, "--stats [FILE]", "-s", "Output statistics in TSV format", default: DEFAULT_OUTPUT
        option :stats_targets,
               "--stats-targets TARGETs",
               "  Statistics targets", Array,
               "    target can be one of #{DEFAULT_TARGETS.join(", ")}, or etc."
      end

      def initialize(*)
        super

        @stats_data = {}
        @stats_targets = options[:stats_targets] || DEFAULT_TARGETS
      end

      def close
        print_statistics
        super
      end

      private

      def init_output_destination
        super
        return unless output_directory?

        raise CommandLineOptionError, "output to directory is not supported for statistics"
      end

      def build_stat_data
        @stats_targets.each_with_object({}) do |target, hash|
          hash[target] = []
        end
      end

      def print_data(_output, data)
        stat_data = @stats_data[data.values_at(CONTROLLER, ACTION)] ||= build_stat_data
        stat_data.each do |target, values|
          value = if target == STAT_TOTAL_DURATION
                    data[DURATION]
                  else
                    data[PERFORMANCE][target]
                  end
          values << value if value
        end
      end

      def print_statistics
        print_row ["percentile", *PERCENTILES]

        @stats_data.keys.sort.each do |(controller, action)|
          @stats_data[[controller, action]].each do |target, values|
            next if values.empty?

            print_row ["#{controller}##{action} #{target}",
                       *PERCENTILES.map { |percentile| values.percentile(percentile) }]
          end
        end
      end

      def print_row(values)
        @output_file.puts values.join("\t")
      end
    end
  end
end
