# frozen_string_literal: true

require "time"

module SelectRailsLog
  class Scanner
    include Constants

    reqid_regexp = /\[(?<reqid>\h{8}-\h{4}-\h{4}-\h{4}-\h{12})\]/
    LOG_REGEXP = /\A., \[(?<time>\S+) #(?<pid>\d+)\]  *(?<severity>\S+) -- :(?: #{reqid_regexp})? (?<message>.*)/
    ANSI_ESCAPE_SEQ_REGEXP = /\e\[(?:\d{1,2}(?:;\d{1,2})?)?[mK]/
    DEBUG = "DEBUG"

    def initialize(io)
      @io = io
    end

    def select(selector)
      buff = {}
      prev_time = nil
      found = false

      @io.each_line do |line|
        m = LOG_REGEXP.match(line)
        next unless m

        pid = m[:pid]
        reqid = m[:reqid]
        message = m[:message]
        time = Time.parse(m[:time])
        log = {
          TIME => time,
          MESSAGE => message,
          SEVERITY => m[:severity],
          SEVERITY_DEBUG => m[:severity] == DEBUG
        }

        ident = reqid || pid
        data = buff[ident] if buff.key?(ident)

        if /\AStarted (?<http_method>\S+) "(?<path>[^"]*)" for (?<client>\S+)/ =~ message
          buff.delete(ident)

          log[INTERVAL] = 0.0
          prev_time = time

          data = {
            ID => reqid || time.strftime("%Y%m%d-%H%M%S-%6N-#{pid}"),
            STARTED => time,
            PID => pid,
            REQUEST_ID => reqid,
            HTTP_METHOD => http_method,
            PATH => path,
            CLIENT => client,
            LOGS => [log],
            RAW_LOGS => [line]
          }
          buff[ident] = data
          next
        end
        next unless data

        message.gsub!(ANSI_ESCAPE_SEQ_REGEXP, "")
        log[INTERVAL] = time - prev_time
        prev_time = time

        if /\AProcessing by (?<controller>[^\s#]+)#(?<action>\S+)/ =~ message
          data[CONTROLLER] = controller
          data[ACTION] = action
          data[LOGS] << log
          data[RAW_LOGS] << line

          buff.delete(ident) unless selector.run_request_filters(data)
        elsif /\A  Parameters: (?<params>.*)/ =~ message
          data[PARAMETERS] = params
          data[LOGS] << log
          data[RAW_LOGS] << line
        elsif /\ACompleted (?<http_status>\d+) .* in (?<duration>\d+)ms \((?<durations>.*)\)/ =~ message
          data[HTTP_STATUS] = http_status
          data[DURATION] = duration.to_i
          data[PERFORMANCE] = durations.scan(/(\S+): (\d+(\.\d+)?)/)
                                       .to_h { |type, dur, dur_f| [type, dur_f ? dur.to_f : dur.to_i] }
          data[COMPLETED] = time
          data[LOGS] << log
          data[RAW_LOGS] << line

          selector.run_line_filters(data) do |i|
            yield(i)
            found = true
          end
          buff.delete(ident)
        else
          data[LOGS] << log
          data[RAW_LOGS] << line
        end
      end

      found
    end
  end
end
