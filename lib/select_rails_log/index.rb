# frozen_string_literal: true

require "time"

module SelectRailsLog
  class Index
    reqid_regexp = /\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/
    LOG_REGEXP = /\A., \[(?<time>\S+) #(?<pid>\d+)\]  *(?<severity>\S+) -- :(?: \[(?<reqid>#{reqid_regexp})\])? (?<message>.*)/
    ANSI_ESCAPE_SEQ_REGEXP = /\e\[(?:\d{1,2}(?:;\d{1,2})?)?[mK]/

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
        log = { time: time, severity: m[:severity], message: message }

        ident = reqid || pid
        data = buff[ident] if buff.key?(ident)

        if /\AStarted (?<http_method>\S+) "(?<path>[^"]*)" for (?<client>\S+)/ =~ message
          buff.delete(ident)

          log[:interval] = 0.0
          prev_time = time

          data = {
            id: reqid || time.strftime("#{pid}-%Y%m%d-%H%M%S-%6N"),
            begin_time: time,
            pid: pid,
            request_id: reqid,
            http_method: http_method,
            path: path,
            client: client,
            logs: [log],
            orig_logs: [line]
          }
          buff[ident] = data
          next
        end
        next unless data

        message.gsub!(ANSI_ESCAPE_SEQ_REGEXP, "")
        log[:interval] = time - prev_time
        prev_time = time

        if /\AProcessing by (?<controller>[^\s#]+)#(?<action>\S+)/ =~ message
          data[:controller] = controller
          data[:action] = action
          data[:logs] << log
          data[:orig_logs] << line

          buff.delete(ident) unless selector.pre_filter(data)
        elsif /\A  Parameters: (?<params>.*)/ =~ message
          data[:parameters] = params
          data[:logs] << log
          data[:orig_logs] << line
        elsif /\ACompleted (?<http_status>\d+) .* in (?<duration>\d+)ms/ =~ message
          data[:http_status] = http_status
          data[:duration] = duration.to_i
          data[:end_time] = time
          data[:logs] << log
          data[:orig_logs] << line

          selector.run(data) do |i|
            yield(i)
            found = true
          end
          buff.delete(ident)
        else
          data[:logs] << log
          data[:orig_logs] << line
        end
      end

      found
    end
  end
end
