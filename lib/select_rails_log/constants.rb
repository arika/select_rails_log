# frozen_string_literal: true

require "time"

module SelectRailsLog
  module Constants
    DEFAULT_OUTPUT = Object.new

    # data keys
    ACTION = "action"
    CLIENT = "client"
    COMPLETED = "completed"
    CONTROLLER = "controller"
    DURATION = "duration"
    HTTP_METHOD = "http_method"
    HTTP_STATUS = "http_status"
    ID = "id"
    INTERVAL = "interval"
    LOGS = "logs"
    MESSAGE = "message"
    PARAMETERS = "parameters"
    PATH = "path"
    PERFORMANCE = "performance"
    PERFORMANCE_ACTIVE_RECORD = "ActiveRecord"
    PERFORMANCE_ALLOCATIONS = "Allocations"
    PERFORMANCE_VIEWS = "Views"
    PID = "pid"
    REQUEST_ID = "request_id"
    RAW_LOGS = "raw_logs"
    SEVERITY = "severity"
    SEVERITY_DEBUG = "severity_debug"
    STARTED = "started"
    TIME = "time"
  end
end
