# frozen_string_literal: true

require "test_helper"
require_relative "printer_test_utils"

class JsonlPrinterTest < Test::Unit::TestCase
  include TestUtils
  include PrinterTestUtils

  setup do
    @log = File.read("#{__dir__}/../data/simple.log")
  end

  test "print in jsonl format" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--jsonl], input:, output:)

    detail = JSON.parse(output.string.lines.first)

    assert_equal FIRST_LOG_DETAIL, detail
  end

  test "exclude deubg" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--jsonl --exclude-debug-logs], input:, output:)

    detail = JSON.parse(output.string.lines.first)

    expected = FIRST_LOG_DETAIL.merge("logs" => FIRST_LOG_DETAIL["logs"].reject { |log| log["severity"] == "DEBUG" })
    assert_equal expected, detail
  end

  test "invalid time" do
    @log.gsub!("2024-12-15T", "2024-12-32T")
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--jsonl], input:, output:)

    detail = JSON.parse(output.string.lines.first)

    assert_equal(
      {
        "started" => nil, "completed" => nil,
        "request_id" => "2ffd7a51-489c-4892-9fec-9dd6172f69e2"
      },
      detail.slice("started", "completed", "request_id")
    )
  end
end
