# frozen_string_literal: true

require_relative "data_serializable"

module SelectRailsLog
  module Printer
    class JsonlPrinter < BasePrinter
      include DataSerializable

      SUFFIX = ".jsonl"

      define_options :jsonl_printer do
        option :output, "--jsonl [PATH]", "-J", "Output in JSON Lines format", default: DEFAULT_OUTPUT
      end

      def runnable?
        !!@options[:output]
      end

      private

      def print_data(output, data)
        output.puts JSON.fast_generate(serialize_data(data))
      end
    end
  end
end
