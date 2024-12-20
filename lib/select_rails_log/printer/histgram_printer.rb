# frozen_string_literal: true

require "unicode_plot"

module SelectRailsLog
  module Printer
    class HistgramPrinter < BasePrinter
      PLOT_TOTAL_DURATION = "Total duration"

      define_options :histgram_printer do
        option :output, "--histgram [FILE]", "-H", "Output statistics histgram", default: DEFAULT_OUTPUT
        option :nbins, "--histgram-nbins NUM", "  Number of bins for histgram", Integer
      end

      def initialize(*)
        super

        @plot_data = []
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

        UnicodePlot
          .histogram(@plot_data, title: PLOT_TOTAL_DURATION, nbins: options[:nbins])
          .render(@output_file)
      end

      def print_data(_output, data)
        @plot_data << data[DURATION]
      end
    end
  end
end
