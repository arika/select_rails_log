# frozen_string_literal: true

require "test_helper"

class ScannerTest < Test::Unit::TestCase
  include TestUtils

  test "null input" do
    output = StringIO.new
    refute select_rails_log(output:)
    assert_equal "", output.string
  end

  test "simple case" do
    input = StringIO.new(File.read("#{__dir__}/data/simple.log"))
    output = StringIO.new
    assert select_rails_log(input:, output:)

    [
      {
        started: "2024-12-15T22:40:07.689566", completed: "2024-12-15T22:40:07.726132",
        request_id: "2ffd7a51-489c-4892-9fec-9dd6172f69e2"
      },
      {
        started: "2024-12-15T22:40:16.522651", completed: "2024-12-15T22:40:17.005013",
        request_id: "64cb3ea6-fa8a-4a60-98f9-97ca9c1f7ede"
      },
      {
        started: "2024-12-15T22:40:17.009694", completed: "2024-12-15T22:40:17.027046",
        request_id: "d52d405c-01c6-481e-95f7-a48265c7cd16"
      },
      {
        started: "2024-12-15T22:40:56.912283", completed: "2024-12-15T22:40:56.960128",
        request_id: "86b2f5b4-206b-4798-bf9e-3952ef87ec9a"
      },
      {
        started: "2024-12-15T22:41:14.717098", completed: "2024-12-15T22:41:14.744251",
        request_id: "81337fae-ad2f-49d4-b461-c442ee3fea74"
      },
      {
        started: "2024-12-15T22:42:12.338460", completed: "2024-12-15T22:42:12.376636",
        request_id: "ccb5e79b-4b2a-479f-be36-df12378358ff"
      },
      {
        started: "2024-12-15T22:42:22.232758", completed: "2024-12-15T22:42:22.259118",
        request_id: "52ac2db0-7e6c-4ff6-8dd7-52f0644af397"
      }
    ].each do |expected|
      assert_includes output.string, <<~TEXT
        time: #{expected[:started]} .. #{expected[:completed]}
        request_id: #{expected[:request_id]}
      TEXT
    end
  end

  test "skip non-started or non-completed items" do
    lines = File.readlines("#{__dir__}/data/simple.log")
    lines.reject! do |line|
      (line.include?("64cb3ea6-fa8a-4a60-98f9-97ca9c1f7ede") && line.include?("Started")) ||
        (line.include?("d52d405c-01c6-481e-95f7-a48265c7cd16") && line.include?("Completed")) ||
        (line.include?("86b2f5b4-206b-4798-bf9e-3952ef87ec9a") && line.include?("Processing")) ||
        (line.include?("81337fae-ad2f-49d4-b461-c442ee3fea74") && line.include?("Parameters"))
    end

    input = StringIO.new(lines.join)
    output = StringIO.new
    assert select_rails_log(input:, output:)
    assert_equal(
      %w[
        2ffd7a51-489c-4892-9fec-9dd6172f69e2
        86b2f5b4-206b-4798-bf9e-3952ef87ec9a
        81337fae-ad2f-49d4-b461-c442ee3fea74
        ccb5e79b-4b2a-479f-be36-df12378358ff
        52ac2db0-7e6c-4ff6-8dd7-52f0644af397
      ].sort,
      output.string.scan(/^request_id: (.+)$/).flatten.sort
    )
  end

  test "accept invalid date/time items" do
    lines = File.readlines("#{__dir__}/data/simple.log")
    lines.each do |line|
      case line
      when /d52d405c-01c6-481e-95f7-a48265c7cd16/
        line.sub!("T22:40:17", "T22:40:60")
      when /86b2f5b4-206b-4798-bf9e-3952ef87ec9a/
        line.sub!("2024-12-15T", "2023-02-29T")
      when /ccb5e79b-4b2a-479f-be36-df12378358ff/
        line.sub!("T22:42:12", "T22:42:61")
      when /52ac2db0-7e6c-4ff6-8dd7-52f0644af397/
        line.sub!("2024-12-15T", "2024-13-15T")
      end
    end

    input = StringIO.new(lines.join)
    output = StringIO.new
    assert select_rails_log(input:, output:)
    [
      {
        started: "2024-12-15T22:41:00.009694", completed: "2024-12-15T22:41:00.027046",
        request_id: "d52d405c-01c6-481e-95f7-a48265c7cd16"
      },
      {
        started: "2023-03-01T22:40:56.912283", completed: "2023-03-01T22:40:56.960128",
        request_id: "86b2f5b4-206b-4798-bf9e-3952ef87ec9a"
      },
      {
        started: "", completed: "",
        request_id: "ccb5e79b-4b2a-479f-be36-df12378358ff"
      },
      {
        started: "", completed: "",
        request_id: "52ac2db0-7e6c-4ff6-8dd7-52f0644af397"
      }
    ].each do |expected|
      assert_includes output.string, <<~TEXT
        time: #{expected[:started]} .. #{expected[:completed]}
        request_id: #{expected[:request_id]}
      TEXT
    end
  end

  test "overlapped case" do
    input = StringIO.new(File.read("#{__dir__}/data/overlapped.log"))
    output = StringIO.new
    assert select_rails_log(input:, output:)

    [
      {
        started: "2024-12-15T22:44:45.515274", completed: "2024-12-15T22:44:45.544224",
        request_id: "5989416a-5d9a-49b1-92e5-54ef00e0e38c"
      },
      {
        started: "2024-12-15T22:44:45.524606", completed: "2024-12-15T22:44:45.550128",
        request_id: "88a6d51e-f6cd-4969-bdc9-f2cebdfbea98"
      },
      {
        started: "2024-12-15T22:44:45.545524", completed: "2024-12-15T22:44:46.027436",
        request_id: "06df5c81-c6dc-48f2-957c-7550a854ad00"
      }
    ].each do |expected|
      assert_includes output.string, <<~TEXT
        time: #{expected[:started]} .. #{expected[:completed]}
        request_id: #{expected[:request_id]}
      TEXT
    end
  end
end
