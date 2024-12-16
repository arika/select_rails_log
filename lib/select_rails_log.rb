# frozen_string_literal: true

require_relative "select_rails_log/constants"
require_relative "select_rails_log/command_line_options"
require_relative "select_rails_log/extension"
require_relative "select_rails_log/filter"
require_relative "select_rails_log/printer"
require_relative "select_rails_log/selector"
require_relative "select_rails_log/runner"
require_relative "select_rails_log/scanner"
require_relative "select_rails_log/version"

module SelectRailsLog
  class Error < RuntimeError; end
  class CommandLineOptionError < Error; end

  class << self
    def run
      exit(Runner.run(ARGV, ARGF) ? 0 : 1)
    end
  end
end
