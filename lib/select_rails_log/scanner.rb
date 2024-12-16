# frozen_string_literal: true

require "time"

module SelectRailsLog
  class Scanner
    include Constants

    reqid_regexp = /\[(?<reqid>\h{8}-\h{4}-\h{4}-\h{4}-\h{12})\]/
    LOG_REGEXP = /\A., \[(?<time>\S+) #(?<pid>\d+)\]  *(?<severity>\S+) -- :(?: #{reqid_regexp})? (?<message>.*)/
    ANSI_ESCAPE_SEQ_REGEXP = /\e\[(?:\d{1,2}(?:;\d{1,2})?)?[mK]/
    DEBUG = "DEBUG"

    DATETIME_FORMAT = "%FT%T.%N"
    REQUEST_FILTER_APPLIED = "request_filter_applied" # internal data keys
    private_constant :DATETIME_FORMAT, :DEBUG, :REQUEST_FILTER_APPLIED

    def initialize(io)
      @io = io
    end

    def select(selector)
      buff = {}
      prev_time = nil
      prev_data = nil
      found = false

      @io.each_line do |line|
        m = LOG_REGEXP.match(line)
        unless m
          if prev_data && prev_data[LOGS].any?
            prev_data[LOGS].last[MESSAGE] << "\n" << line.chomp.gsub(ANSI_ESCAPE_SEQ_REGEXP, "")
            prev_data[RAW_LOGS].last << line
          end
          next
        end

        pid = m[:pid]
        reqid = m[:reqid]
        message = m[:message]
        time = Time.strptime(m[:time], DATETIME_FORMAT)
        log = {
          TIME => time,
          MESSAGE => message,
          SEVERITY => m[:severity],
          SEVERITY_DEBUG => m[:severity] == DEBUG
        }

        ident = reqid || pid
        data = prev_data = buff[ident] if buff.key?(ident)

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
            RAW_LOGS => [line],
            REQUEST_FILTER_APPLIED => false
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

          data.delete(REQUEST_FILTER_APPLIED)
          unless selector.run_request_filters(data)
            buff.delete(ident)
            prev_data = nil
          end
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

          if data.key?(REQUEST_FILTER_APPLIED)
            data.delete(REQUEST_FILTER_APPLIED)
            reqf_result = selector.run_request_filters(data)
          else
            reqf_result = true
          end

          reqf_result && selector.run_line_filters(data) do |i|
            yield(i)
            found = true
          end
          buff.delete(ident)
          prev_data = nil
        else
          data[LOGS] << log
          data[RAW_LOGS] << line
        end
      end

      found
    end
  end
end
