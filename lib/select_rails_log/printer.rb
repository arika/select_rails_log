# frozen_string_literal: true

module SelectRailsLog
  class Printer
    module Driver
      class Base
        def initialize(output_directory:, include_debug:)
          @output_directory = output_directory
          @include_debug = include_debug
        end

        def print(data)
          with_output(data) do |output|
            print_data(output, data)
          end
        end

        private

        def suffix
          self.class::SUFFIX
        end

        def print_data(_output, _data)
          raise NotImplementedError
        end

        def with_output(data, &block)
          return yield($stdout) unless @output_directory

          file = data[:id]
          sub_dir = file[-2, 2]
          dir = "#{@output_directory}/#{sub_dir}"
          FileUtils.mkdir_p(dir)
          File.open("#{dir}/#{file}#{suffix}", File::CREAT | File::TRUNC | File::WRONLY, &block)
        end

        def select_logs(data)
          logs = []
          data[:logs].each do |log|
            next unless @include_debug || log[:severity] != "DEBUG"

            if block_given?
              logs = yield(log)
            else
              logs << log
            end
          end
          logs
        end
      end

      class Null < Base
        private

        def print_data(*); end
      end

      class Text < Base
        DATETIME_FORMAT = "%FT%T.%6N"
        SUFFIX = ".txt"

        private

        def print_data(output, data)
          print_header(output, data)
          print_body(output, data)
          output.puts unless @output_directory
        end

        def print_header(output, data)
          output.puts "time: #{data[:begin_time].strftime(DATETIME_FORMAT)} " \
                      ".. #{data[:end_time].strftime(DATETIME_FORMAT)}"
          output.puts "request_id: #{data[:request_id]}" if data[:request_id]
          output.print <<~END_OF_HEADER
            pid: #{data[:pid]}
            status: #{data[:http_status]}
            duration: #{data[:duration]}ms
          END_OF_HEADER
        end

        def print_body(output, data)
          select_logs(data) do |log|
            output.printf "[%<interval>8.3f] %<message>s\n", interval: log[:interval] * 1_000, message: log[:message]
          end
        end
      end

      class Json < Base
        DATETIME_FORMAT = "%FT%T.%6N%:z"
        SUFFIX = ".json"

        private

        def print_data(output, data)
          json = data.slice(
            :request_id, :http_status, :http_method, :controller, :action,
            :duration, :path, :parameters, :client
          )

          json[:begin_time] = data[:begin_time].strftime(DATETIME_FORMAT)
          json[:end_time] = data[:end_time].strftime(DATETIME_FORMAT)
          json[:pid] = data[:pid].to_i

          json[:logs] = []
          select_logs(data) do |log|
            json[:logs] << log.merge(time: log[:time].strftime(DATETIME_FORMAT))
          end

          output.puts JSON.fast_generate(json)
        end
      end

      class Raw < Base
        SUFFIX = ".log"

        private

        def print_data(output, data)
          if data.key?(:orig_logs)
            output.puts data[:orig_logs]
            return
          end

          data[:logs].each do |log|
            output.printf(
              "%<sev>s, [%<time>s #%<pid>d] %<sevirity>5s -- : %<reqid>s%<message>s\n",
              sev: log[:severity][0],
              sevirity: log[:severity],
              time: log[:time].strftime("%FT%T.%6N"),
              pid: data[:pid],
              reqid: data[:request_id] ? "[#{data[:request_id]}] " : "",
              message: log[:message]
            )
          end
        end
      end

      class Groonga < Base
        def initialize(*)
          super
          raise ArgumentError, "output directory is required" unless @output_directory

          FileUtils.mkdir_p(@output_directory)
          @groonga_index = GroongaIndex.new(@output_directory, create: true)
        end

        def print(data)
          data[:logs] = select_logs(data)
          @groonga_index.store(data)
        end
      end
    end

    DRIVERS = {
      text: Driver::Text,
      json: Driver::Json,
      raw: Driver::Raw,
      null: Driver::Null,
      groonga: Driver::Groonga
    }.freeze

    attr_accessor :output_directory, :include_debug

    def initialize
      @output_directory = nil
      @include_debug = true
      @driver = nil
      self.driver_class = :text
    end

    def driver_class=(type)
      @driver_class = drivers[type]
      raise ArgumentError unless @driver_class
    end

    def print(data)
      @driver ||= initialize_driver
      @driver.print(data)
    end

    private

    def initialize_driver
      @driver_class.new(output_directory: output_directory, include_debug: @include_debug)
    end

    def drivers
      self.class::DRIVERS
    end
  end
end
