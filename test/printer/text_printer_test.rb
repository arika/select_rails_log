# frozen_string_literal: true

require "test_helper"
require_relative "printer_test_utils"

class TextPrinterTest < Test::Unit::TestCase
  include TestUtils
  include PrinterTestUtils

  setup do
    @log = File.read("#{__dir__}/../data/simple.log")
  end

  test "print in text format" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(input:, output:)

    expected = <<~TEXT
      time: #{FIRST_LOG_DETAIL["started"][..-7]} .. #{FIRST_LOG_DETAIL["completed"][..-7]}
      request_id: #{FIRST_LOG_DETAIL["request_id"]}
      pid: #{FIRST_LOG_DETAIL["pid"]}
      status: #{FIRST_LOG_DETAIL["http_status"]}
      duration: #{FIRST_LOG_DETAIL["duration"]}ms
    TEXT
    FIRST_LOG_DETAIL["logs"].each do |log|
      expected << format("[%<interval>8.3f] %<message>s\n", interval: log["interval"] * 1_000, message: log["message"])
    end
    assert_equal expected, output.string.split(/^$/, 0).first
  end

  test "exclude deubg" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--exclude-debug-logs], input:, output:)

    expected = <<~TEXT
      time: #{FIRST_LOG_DETAIL["started"][..-7]} .. #{FIRST_LOG_DETAIL["completed"][..-7]}
      request_id: #{FIRST_LOG_DETAIL["request_id"]}
      pid: #{FIRST_LOG_DETAIL["pid"]}
      status: #{FIRST_LOG_DETAIL["http_status"]}
      duration: #{FIRST_LOG_DETAIL["duration"]}ms
    TEXT
    FIRST_LOG_DETAIL["logs"].values_at(0, 1, 4, 7, 8).each do |log|
      expected << format("[%<interval>8.3f] %<message>s\n", interval: log["interval"] * 1_000, message: log["message"])
    end
    assert_equal expected, output.string.split(/^$/, 0).first
  end

  test "invalid time" do
    @log.gsub!("2024-12-15T", "2024-12-32T")
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(input:, output:)

    assert_equal "time:  .. \n" \
                 "request_id: 2ffd7a51-489c-4892-9fec-9dd6172f69e2\n",
                 output.string.lines[0, 2].join
  end
end
