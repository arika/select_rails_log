# frozen_string_literal: true

require "unicode_plot"
require "io/console"

module SelectRailsLog
  module Printer
    class BoxplotPrinter < BasePrinter
      PLOT_TOTAL_DURATION = "Total duration"

      define_options :boxplot_printer do
        option :output, "--boxplot [FILE]", "-B", "Output statistics boxplot", default: DEFAULT_OUTPUT
        option :min, "--boxplot-min MIN", "  Minimum value for boxplot", Float
        option :max, "--boxplot-max MAX", "  Maximum value for boxplot", Float
        option :width, "--boxplot-width NUM", "  Width of boxplot column", Integer
      end

      def initialize(*)
        super

        @plot_data = Hash.new { |h, k| h[k] = [] }
        @controller_actions = Hash.new { |h, k| h[k] = {} }
      end

      def close
        print_plot
        super
      end

      private

      def init_output_destination
        super
        return unless output_directory?

        raise CommandLineOptionError, "output to directory is not supported for plot"
      end

      def print_plot
        return if @plot_data.empty?

        boxplot.render(@output_file)
      end

      def boxplot
        opts = {
          title: PLOT_TOTAL_DURATION,
          data: @plot_data.keys.sort.each_with_object({}) { |k, h| h[k] = @plot_data[k] },
          width: boxplot_width,
          xlim: boxplot_xlim
        }.compact
        UnicodePlot.boxplot(**opts)
      end

      def boxplot_width
        return options[:width] if options[:width]

        begin
          _rows, cols = @output_file.winsize
        rescue Errno::ENOTTY, Errno::ENODEV, NoMethodError
          return nil
        end

        cols - @plot_data.keys.map(&:size).max - 8
      end

      def boxplot_xlim
        return unless options[:min] || options[:max]

        [
          options[:min] || 0,
          options[:max] || 0
        ]
      end

      def print_data(_output, data)
        controller, action = data.values_at(CONTROLLER, ACTION)
        controller_action = @controller_actions[controller][action] ||= "#{controller}##{action}"
        @plot_data[controller_action] << data[DURATION]
      end
    end
  end
end
