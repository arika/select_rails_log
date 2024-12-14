# frozen_string_literal: true

require_relative "data_serializable"

module SelectRailsLog
  module Printer
    class JsonPrinter < BasePrinter
      include DataSerializable

      SUFFIX = ".json"

      define_options :json_printer do
        option :output, "--json [PATH]", "-j", "Output in JSON format", default: DEFAULT_OUTPUT
      end

      def initialize(...)
        super
        @no_output = true
      end

      def close
        @output_file.puts "]" unless output_directory?
        super
      end

      private

      def print_data(output, data)
        unless output_directory?
          if @no_output
            output.print "["
            @no_output = false
          else
            output.print ","
          end
        end

        output.print JSON.fast_generate(serialize_data(data))
        output.puts if output_directory?
      end
    end
  end
end
