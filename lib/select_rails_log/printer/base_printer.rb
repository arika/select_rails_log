# frozen_string_literal: true

require "fileutils"

module SelectRailsLog
  module Printer
    class BasePrinter < Extension
      include Constants

      define_options :base_printer do
        separator ""
        separator "printer options:"

        option :default_output, "--default-output PATH", "-O", "Output to file or directory"
        option :exclude_debug_logs, "--exclude-debug-logs", "-x", "Exclude debug logs"
      end

      OUTPUT_FILE_DATETIME_FORMAT = "%Y%m%d-%H%M%S.%6N"
      private_constant :OUTPUT_FILE_DATETIME_FORMAT

      def initialize(options, standard_output)
        super(options)

        @common_options = @whole_options[:base_printer]
        @output_file = @standard_output = standard_output
        @output_filename = @output_directory = nil
        init_output_destination

        @prepared = false
      end

      def close
        @output_file&.close unless output_directory? || output_stdout?
      end

      def print(data)
        unless @prepared
          prepare
          @prepared = true
        end

        with_output(data) do |io|
          print_data(io, data)
        end
      end

      def runnable?
        !!output_option
      end

      def output_stdout?
        !output_directory? && @output_file == @standard_output
      end

      def output_directory?
        !!@output_directory
      end

      private

      def init_output_destination
        dest = output_option
        dest = @common_options[:default_output] if dest == DEFAULT_OUTPUT
        return if !dest || dest == "-"

        if dest.end_with?("/")
          @output_directory = dest.chomp("/")
        elsif File.directory?(dest)
          @output_directory = dest
        else
          @output_filename = dest
        end
      end

      def output_option
        options.key?(:output) && options[:output]
      end

      def prepare
        return unless @output_filename

        @output_file = File.open(@output_filename, "w")
      end

      def with_output(data, &)
        return yield(@output_file) unless output_directory?

        FileUtils.mkdir_p(@output_directory)
        File.open("#{@output_directory}/#{output_filename(data)}",
                  File::CREAT | File::TRUNC | File::WRONLY, &)
      end

      def output_filename(data)
        timestr = data[STARTED].strftime(OUTPUT_FILE_DATETIME_FORMAT)
        "#{timestr}_#{data[ID]}#{self.class::SUFFIX}"
      end

      def print_data(_output, _data)
        raise NotImplementedError
      end

      def each_log_with_index(data)
        data[LOGS].each_with_index do |log, i|
          next if @common_options[:exclude_debug_logs] && log[SEVERITY_DEBUG]

          yield(log, i)
        end
      end

      def each_log(data)
        each_log_with_index(data) do |log, _i|
          yield(log)
        end
      end
    end
  end
end
