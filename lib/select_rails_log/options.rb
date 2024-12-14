# frozen_string_literal: true

require "forwardable"

module SelectRailsLog
  class Options
    extend Forwardable

    def_delegators :@options, :key?, :[]=

    def initialize
      @options = {}
    end

    def fetch(key)
      @options.fetch(key)
    end
    alias [] fetch
  end
end
