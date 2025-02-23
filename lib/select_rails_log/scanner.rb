# frozen_string_literal: true

require "time"

module SelectRailsLog
  class Scanner
    include Constants

    reqid_regexp = /\[(?<reqid>\h{8}-\h{4}-\h{4}-\h{4}-\h{12})\]/
    LOG_REGEXP = /\A., \[(?<time>\S+) #(?<pid>\d+)\]  *(?<severity>\S+) -- :(?: #{reqid_regexp})? (?<message>.*)/
    ANSI_ESCAPE_SEQ_REGEXP = /\e\[(?:\d{1,2}(?:;\d{1,2})?)?[mK]/

    DATETIME_FORMAT = "%FT%T.%N"
    REQUEST_FILTER_APPLIED = "request_filter_applied" # internal data keys
    private_constant :DATETIME_FORMAT, :REQUEST_FILTER_APPLIED

    def initialize(io)
      @io = io
    end

    def select(selector, keep_raw: true)
      buff = {}
      prev_time = nil
      prev_data = nil
      found = false
      stop_iteration = false

      @io.each_line do |line|
        m = LOG_REGEXP.match(line)
        unless m
          if prev_data && prev_data[LOGS].any?
            prev_data[LOGS].last[MESSAGE] << "\n" << line.chomp.gsub(ANSI_ESCAPE_SEQ_REGEXP, "")
            prev_data[RAW_LOGS].last << line if keep_raw
          end
          next
        end

        begin
          time = Time.strptime(m[:time], DATETIME_FORMAT)
        rescue ArgumentError
          # ignore invalid time format
        end

        pid = m[:pid]
        reqid = m[:reqid]
        message = m[:message]
        log = {
          TIME => time,
          MESSAGE => message,
          SEVERITY => m[:severity]
        }

        ident = reqid || pid
        data = prev_data = buff[ident] if buff.key?(ident)

        if /\A(?:\[.*\] )?Started (?<http_method>\S+) "(?<path>[^"]*)" for (?<client>\S+)/ =~ message
          buff.delete(ident)
          if stop_iteration
            prev_data = nil
            buff.empty? ? break : next
          end

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
            REQUEST_FILTER_APPLIED => false
          }
          data[RAW_LOGS] = [line] if keep_raw
          buff[ident] = data
          next
        end

        unless data
          prev_data = nil
          next
        end

        message.gsub!(ANSI_ESCAPE_SEQ_REGEXP, "")
        log[INTERVAL] = (time && prev_time) ? time - prev_time : 0.0
        prev_time = time

        if /\A(?:\[.*\] )?Processing by (?<controller>[^\s#]+)#(?<action>\S+)/ =~ message
          data[CONTROLLER] = controller
          data[ACTION] = action
          data[LOGS] << log
          data[RAW_LOGS] << line if keep_raw

          data.delete(REQUEST_FILTER_APPLIED)
          begin
            reqf_result = selector.run_request_filters(data)
          rescue StopIteration
            stop_iteration = true
          end
          if !reqf_result || stop_iteration
            buff.delete(ident)
            prev_data = nil
          end
        elsif /\A(?:\[.*\] )?  Parameters: (?<params>.*)/ =~ message
          data[PARAMETERS] = params
          data[LOGS] << log
          data[RAW_LOGS] << line if keep_raw
        elsif /\A(?:\[.*\] )?Completed (?<http_status>\d+) .* in (?<duration>\d+)ms \((?<durations>.*)\)/ =~ message
          data[HTTP_STATUS] = http_status
          data[DURATION] = duration.to_i
          data[PERFORMANCE] = durations.scan(/(\S+): (\d+(\.\d+)?)/)
                                       .to_h { |type, dur, dur_f| [type, dur_f ? dur.to_f : dur.to_i] }
          data[COMPLETED] = time
          data[LOGS] << log
          data[RAW_LOGS] << line if keep_raw

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
          data[RAW_LOGS] << line if keep_raw
        end
      end

      found
    end
  end
end
