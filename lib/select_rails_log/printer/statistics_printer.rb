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

        @stats_data = (options[:stats_targets] || DEFAULT_TARGETS).each_with_object({}) do |target, hash|
          hash[target] = []
        end
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

      def print_data(_output, data)
        @stats_data.each_key do |key|
          if key == STAT_TOTAL_DURATION
            push_value(key, data[DURATION])
          else
            push_value(key, data[PERFORMANCE][key])
          end
        end
      end

      def push_value(key, value)
        @stats_data[key] << value if value
      end

      def print_statistics
        print_row ["", *PERCENTILES.map { |percentile| "p#{percentile}" }]

        @stats_data.each do |key, values|
          next if values.empty?

          print_row [key, *PERCENTILES.map { |percentile| values.percentile(percentile) }]
        end
      end

      def print_row(values)
        @output_file.puts values.join("\t")
      end
    end
  end
end
