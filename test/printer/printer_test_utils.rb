# frozen_string_literal: true

module PrinterTestUtils
  tz = Time.now.strftime("%:z")
  FIRST_LOG_DETAIL = {
    "started" => "2024-12-15T22:40:07.689566#{tz}", "completed" => "2024-12-15T22:40:07.726132#{tz}",
    "request_id" => "2ffd7a51-489c-4892-9fec-9dd6172f69e2",
    "pid" => 48158, # rubocop:disable Style/NumericLiterals
    "http_status" => "200",
    "http_method" => "GET",
    "path" => "/login",
    "controller" => "SessionsController",
    "action" => "new",
    "client" => "127.0.0.1",
    "performance" => {
      "ActiveRecord" => 0.0,
      "Views" => 21.9,
      "Allocations" => 9931
    },
    "duration" => 24,
    "logs" => [
      {
        "time" => "2024-12-15T22:40:07.689566#{tz}",
        "severity" => "INFO",
        "severity_debug" => false,
        "message" => "Started GET \"/login\" for 127.0.0.1 at 2024-12-15 22:40:07 +0900",
        "interval" => 0.0
      },
      {
        "time" => "2024-12-15T22:40:07.702238#{tz}",
        "severity" => "INFO",
        "severity_debug" => false,
        "message" => "Processing by SessionsController#new as HTML",
        "interval" => Time.parse("2024-12-15T22:40:07.702238") - Time.parse("2024-12-15T22:40:07.689566")
      },
      {
        "time" => "2024-12-15T22:40:07.705488#{tz}",
        "severity" => "DEBUG",
        "severity_debug" => true,
        "message" => "  Rendering layout layouts/application.html.erb",
        "interval" => Time.parse("2024-12-15T22:40:07.705488") - Time.parse("2024-12-15T22:40:07.702238")
      },
      {
        "time" => "2024-12-15T22:40:07.705666#{tz}",
        "severity" => "DEBUG",
        "severity_debug" => true,
        "message" => "  Rendering sessions/new.html.erb within layouts/application",
        "interval" => Time.parse("2024-12-15T22:40:07.705666") - Time.parse("2024-12-15T22:40:07.705488")
      },
      {
        "time" => "2024-12-15T22:40:07.718367#{tz}",
        "severity" => "INFO",
        "severity_debug" => false,
        "message" => "  Rendered sessions/new.html.erb within layouts/application (Duration: 12.6ms | Allocations: 2136)", # rubocop:disable Layout/LineLength
        "interval" => Time.parse("2024-12-15T22:40:07.718367") - Time.parse("2024-12-15T22:40:07.705666")
      },
      {
        "time" => "2024-12-15T22:40:07.725138#{tz}",
        "severity" => "DEBUG",
        "severity_debug" => true,
        "message" => "  Rendered layouts/_header.html.erb (Duration: 0.2ms | Allocations: 145)",
        "interval" => Time.parse("2024-12-15T22:40:07.725138") - Time.parse("2024-12-15T22:40:07.718367")
      },
      {
        "time" => "2024-12-15T22:40:07.725344#{tz}",
        "severity" => "DEBUG",
        "severity_debug" => true,
        "message" => "  Rendered layouts/_footer.html.erb (Duration: 0.1ms | Allocations: 67)",
        "interval" => Time.parse("2024-12-15T22:40:07.725344") - Time.parse("2024-12-15T22:40:07.725138")
      },
      {
        "time" => "2024-12-15T22:40:07.725894#{tz}",
        "severity" => "INFO",
        "severity_debug" => false,
        "message" => "  Rendered layout layouts/application.html.erb (Duration: 20.3ms | Allocations: 9302)",
        "interval" => Time.parse("2024-12-15T22:40:07.725894") - Time.parse("2024-12-15T22:40:07.725344")
      },
      {
        "time" => "2024-12-15T22:40:07.726132#{tz}",
        "severity" => "INFO",
        "severity_debug" => false,
        "message" => "Completed 200 OK in 24ms (Views: 21.9ms | ActiveRecord: 0.0ms | Allocations: 9931)",
        "interval" => Time.parse("2024-12-15T22:40:07.726132") - Time.parse("2024-12-15T22:40:07.725894")
      }
    ]
  }.freeze
end
