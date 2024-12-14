# frozen_string_literal: true

require "unicode_plot"
require "io/console"

module SelectRailsLog
  module Printer
    class UnicodePlotPrinter < BasePrinter
      PLOT_HIST = "hist"
      PLOT_BOX = "box"

      PLOT_TOTAL_DURATION = "Total duration"

      define_options :unicode_plot_printer do
        option :histgram_output, "--histgram [FILE]", "-H", "Output statistics histgram", default: DEFAULT_OUTPUT
        option :histgram_nbins, "--histgram-nbins NUM", "  Number of bins for histgram", Integer
        option :boxplot_output, "--boxplot [FILE]", "-B", "Output statistics boxplot", default: DEFAULT_OUTPUT
        option :boxplot_min, "--boxplot-min MIN", "  Minimum value for boxplot", Float
        option :boxplot_max, "--boxplot-max MAX", "  Maximum value for boxplot", Float
        option :boxplot_width, "--boxplot-width NUM", "  Width of boxplot column", Integer
      end

      def initialize(*)
        @plot_type = nil

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

      def output_option
        if plot_type == PLOT_HIST
          options[:histgram_output]
        elsif plot_type == PLOT_BOX
          options[:boxplot_output]
        end
      end

      def plot_type
        return @plot_type if @plot_type

        @plot_type = if options[:histgram_output]
                       PLOT_HIST
                     elsif options[:boxplot_output]
                       PLOT_BOX
                     end
      end

      def print_plot
        return if @plot_data.empty?

        plot = if @plot_type == PLOT_HIST
                 histgram
               elsif @plot_type == PLOT_BOX
                 boxplot
               end
        plot.render(@output_file)
      end

      def histgram
        nbins = options[:histgram_nbins]
        UnicodePlot.histogram(@plot_data[PLOT_TOTAL_DURATION], title: PLOT_TOTAL_DURATION, nbins:)
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
        return options[:boxplot_width] if options[:boxplot_width]

        begin
          _rows, cols = @output_file.winsize
        rescue Errno::ENOTTY, Errno::ENODEV, NoMethodError
          return nil
        end

        cols - @plot_data.keys.map(&:size).max - 8
      end

      def boxplot_xlim
        return unless options[:boxplot_min] || options[:boxplot_max]

        [
          options[:boxplot_min] || 0,
          options[:boxplot_max] || 0
        ]
      end

      def print_data(_output, data)
        if @plot_type == PLOT_HIST
          @plot_data[PLOT_TOTAL_DURATION] << data[DURATION]
        elsif @plot_type == PLOT_BOX
          @plot_data[controller_action(data)] << data[DURATION]
        end
      end

      def controller_action(data)
        controller, action = data.values_at(CONTROLLER, ACTION)
        @controller_actions[controller][action] ||= "#{controller}##{action}"
      end
    end
  end
end
