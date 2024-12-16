# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "select_rails_log"
require "test-unit"

module TestUtils
  def select_rails_log(args: [], input: StringIO.new, output: StringIO.new)
    SelectRailsLog::Runner.run(args, input, output)
  end

  def run_filter(args)
    input = StringIO.new(File.read("#{__dir__}/data/simple.log"))
    output = StringIO.new
    select_rails_log(args:, input:, output:)
    output.string.scan(/^request_id: (\S+)$/).map(&:first)
  end
end
