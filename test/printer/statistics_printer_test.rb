# frozen_string_literal: true

require "test_helper"
require "securerandom"
require "csv"

class StatisticsPrinterTest < Test::Unit::TestCase
  include TestUtils

  setup do
    @log = 101.times.each_with_object(+"") do |i, log|
      reqid = SecureRandom.uuid
      log << <<~LOG
        I, [2024-12-15T22:40:07.689566 #1]  INFO -- : [#{reqid}] Started GET "/" for 127.0.0.1 at 2024-12-15 22:40:07 +0900
        I, [2024-12-15T22:40:07.697231 #1]  INFO -- : [#{reqid}] Processing by SessionsController#new as HTML
        I, [2024-12-15T22:40:07.702238 #1]  INFO -- : [#{reqid}] Completed 200 OK in #{300 + i}ms (Views: #{200 + i}.0ms | ActiveRecord: #{100 + i}.0ms | Allocations: #{1000 + i})
      LOG
    end
  end

  test "print in tsv format" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--stats], input:, output:)

    rows = []
    CSV.parse(output.string, col_sep: "\t", headers: true) do |row|
      rows << row.to_h.values_at("percentile", "25", "50", "75", "90", "95", "99")
    end
    assert_equal(
      [
        ["SessionsController#new Total", "325", "350", "375", "390", "395", "399"],
        ["SessionsController#new ActiveRecord", "125.0", "150.0", "175.0", "190.0", "195.0", "199.0"],
        ["SessionsController#new Views", "225.0", "250.0", "275.0", "290.0", "295.0", "299.0"],
        ["SessionsController#new Allocations", "1025", "1050", "1075", "1090", "1095", "1099"]
      ],
      rows
    )
  end

  test "stats targets" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--stats --stats-targets Total,Views], input:, output:)

    rows = []
    CSV.parse(output.string, col_sep: "\t", headers: true) do |row|
      rows << row.to_h.values_at("percentile", "25", "50", "75", "90", "95", "99")
    end
    assert_equal(
      [
        ["SessionsController#new Total", "325", "350", "375", "390", "395", "399"],
        ["SessionsController#new Views", "225.0", "250.0", "275.0", "290.0", "295.0", "299.0"]
      ],
      rows
    )
  end

  test "multiple controller actions" do
    reqid = SecureRandom.uuid
    @log << <<~LOG
      I, [2024-12-15T22:40:07.689566 #1]  INFO -- : [#{reqid}] Started GET "/" for 127.0.0.1 at 2024-12-15 22:40:07 +0900
      I, [2024-12-15T22:40:07.697231 #1]  INFO -- : [#{reqid}] Processing by SessionsController#create as HTML
      I, [2024-12-15T22:40:07.702238 #1]  INFO -- : [#{reqid}] Completed 200 OK in 1ms (Views: 2.0ms | ActiveRecord: 30ms | Allocations: 4)
    LOG

    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--stats --stats-targets Total], input:, output:)

    rows = []
    CSV.parse(output.string, col_sep: "\t", headers: true) do |row|
      rows << row.to_h.values_at("percentile", "25", "50", "75", "90", "95", "99")
    end
    assert_equal(
      [
        ["SessionsController#create Total", "1", "1", "1", "1", "1", "1"],
        ["SessionsController#new Total", "325", "350", "375", "390", "395", "399"]
      ],
      rows
    )
  end
end
