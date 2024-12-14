# frozen_string_literal: true

module SelectRailsLog
  module Printer
    class NullPrinter < BasePrinter
      define_options :null_printer do
        option :enabled, "--no-output", "-n", "No output", TrueClass
      end

      def runnable?
        !!options[:enabled]
      end

      private

      def print_data(...); end
    end
  end
end
