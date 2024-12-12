# frozen_string_literal: true

require "optparse"

module SelectRailsLog
  class CommandLineOption
    class << self
      def parse(selector:, printer:)
        options = new(selector: selector, printer: printer)
        OptionParser.new do |parser|
          options.define_options(parser)
          parser.parse!
        end
        options
      end
    end

    attr_accessor :debug

    def initialize(selector:, printer:)
      @selector = selector
      @printer = printer
      @debug = false
    end

    def define_options(parser)
      define_banner(parser)
      define_filter_options(parser)
      define_printer_options(parser)
      define_common_options(parser)
    end

    private

    def define_banner(parser)
      parser.banner = "usage: #{$PROGRAM_NAME} [options] [log-files...]"
    end

    def define_filter_options(parser)
      parser.separator ""
      parser.separator "Filter options:"

      define_request_id_option(parser)
      define_controller_action_option(parser)
      define_http_method_option(parser)
      define_http_status_option(parser)
      define_duration_range_option(parser)
      define_time_range_option(parser)
      define_params_regexp_option(parser)
      define_logs_regexp_option(parser)
    end

    def define_printer_options(parser)
      parser.separator ""
      parser.separator "Printer options:"

      define_output_option(parser)
      define_hide_debug_log_option(parser)
      define_raw_printer_option(parser)
      define_json_printer_option(parser)
      define_groonga_printer_option(parser)
      define_null_printer_option(parser)
    end

    def define_common_options(parser)
      parser.separator ""
      parser.separator "Common options:"

      parser.on_tail("--debug", "Enable debug print") do
        self.debug = true
      end

      parser.on_tail("-h", "--help", "Show help") do
        puts parser
        exit
      end
    end

    def define_request_id_option(parser)
      parser.on(
        "-I", "--request-ids=IDS", Array,
        "Filter by request-id"
      ) do |reqids|
        @selector.add_filter(:request_ids, reqids)
      end
    end

    def define_controller_action_option(parser)
      parser.on(
        "-a", "--action-names=NAMES", Array,
        "Filter by controller and action names",
        'ex: "FooController#index,BarController,baz#show,..."'
      ) do |names|
        @selector.add_filter(:controller_actions, names)
      end
    end

    def define_http_status_option(parser)
      parser.on(
        "-s", "--statuses=STATUSES", String,
        "Filter by statuses",
        'ex: "3,20,!201,..."'
      ) do |pattern|
        @selector.add_filter(:http_status, pattern)
      rescue ArgumentError
        raise OptionParser::InvalidArgument, 'expects statuse pattern (ex: "200,302", "3,20,!201,304", or "!4,5")'
      end
    end

    def define_http_method_option(parser)
      parser.on(
        "-m", "--method=METHOD", String,
        "Filter by HTTP method name"
      ) do |http_method|
        @selector.add_filter(:http_method, http_method)
      end
    end

    def define_time_range_option(parser)
      parser.on(
        "-t", "--time-range=TIME_RANGE", String,
        "Filter by time range",
        'ex: "2018-01-02 12:00..2018-02-01 12:00", "1/2 12:00...2/2 12:00", or "3/5,60"'
      ) do |pattern|
        @selector.add_filter(:time_range, pattern)
      rescue ArgumentError
        raise OptionParser::InvalidArgument,
              'expects time range format (ex: "time1..time2", "time1...time2", or "time,delta")'
      end
    end

    def define_duration_range_option(parser)
      parser.on(
        "-d", "--duration-range=DUR_RANGE", String,
        "Filter by duration range [ms]",
        'ex: "10..200", "10...200", or "300,10"'
      ) do |pattern|
        @selector.add_filter(:duration_range, pattern)
      rescue ArgumentError
        raise OptionParser::InvalidArgument,
              'expects duration range format (ex: "ms1..ms2", "ms1...ms2", or "ms,delta")'
      end
    end

    def define_params_regexp_option(parser)
      parser.on(
        "-P", "--params-regexp=REGEXP", Regexp,
        "Filter by parameters",
        %q(ex: '"foo"=>"ba[rz]"')
      ) do |regexp|
        @selector.add_filter(:params_regexp, regexp)
      end
    end

    def define_logs_regexp_option(parser)
      parser.on(
        "-L", "--logs-regexp=REGEXP", Regexp,
        "Filter by log messages",
        %q(ex: '"^  Rendering .*\.json"')
      ) do |regexp|
        @selector.add_filter(:logs_regexp, regexp)
      end
    end

    def define_output_option(parser)
      parser.on(
        "-o", "--output=DIR",
        "Output to directory"
      ) do |dir|
        @printer.output_directory = dir
      end
    end

    def define_hide_debug_log_option(parser)
      parser.on(
        "-D", "--[no-]hide-debug-logs",
        "Hide DEBUG logs"
      ) do |value|
        @printer.include_debug = !value
      end
    end

    def define_json_printer_option(parser)
      parser.on(
        "-J", "--json",
        "Output in JSON"
      ) do
        require "json"
        @printer.driver_class = :json
      end
    end

    def define_groonga_printer_option(parser)
      parser.on(
        "-G", "--groonga",
        "Output to Groonga database"
      ) do
        begin
          require "rroonga"
        rescue LoadError => e
          raise OptionParser::InvalidArgument,
                "requires Groonga library (#{e.message}; try \"gem i rroonga\")"
        end

        begin
          require_relative "groonga_rails_log"
        rescue LoadError => e
          raise OptionParser::InvalidArgument, "requires groonga_rails_log.rb (#{e.message})"
        end

        @printer.driver_class = :groonga
      end
    end

    def define_raw_printer_option(parser)
      parser.on(
        "-R", "--raw",
        "Output in raw format"
      ) do
        @printer.driver_class = :raw
      end
    end

    def define_null_printer_option(parser)
      parser.on(
        "-N", "--no-output",
        "No output"
      ) do
        @printer.driver_class = :null
      end
    end
  end
end
