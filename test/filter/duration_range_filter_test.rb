# frozen_string_literal: true

require "test_helper"

class DurationRangeFilterTest < Test::Unit::TestCase
  include TestUtils

  def run_filter(arg)
    super(%W[--duration-range #{arg}]).sort
  end

  def request_ids(*durations)
    @request_ids.filter_map { |d, request_id| durations.include?(d) ? request_id : nil }.sort
  end

  setup do
    @request_ids = [
      # [duration, request_id]
      [12, "52ac2db0-7e6c-4ff6-8dd7-52f0644af397"],
      [14, "d52d405c-01c6-481e-95f7-a48265c7cd16"],
      [14, "81337fae-ad2f-49d4-b461-c442ee3fea74"],
      [20, "ccb5e79b-4b2a-479f-be36-df12378358ff"],
      [24, "2ffd7a51-489c-4892-9fec-9dd6172f69e2"],
      [33, "86b2f5b4-206b-4798-bf9e-3952ef87ec9a"],
      [468, "64cb3ea6-fa8a-4a60-98f9-97ca9c1f7ede"]
    ]
  end

  test "ms1..ms2" do
    assert_equal request_ids(12), run_filter("11..13")
    assert_equal request_ids(12), run_filter("11..12")
    assert_equal request_ids(12), run_filter("12..13")
    assert_equal request_ids(14, 20, 24), run_filter("13..25")
    assert_empty run_filter("100..200")
  end

  test "ms1...ms2" do
    assert_equal request_ids(12), run_filter("11...13")
    assert_equal request_ids(12), run_filter("12...13")
    assert_empty run_filter("11...12")
    assert_equal request_ids(14, 20, 24), run_filter("13..25")
  end

  test "..ms2" do
    assert_equal request_ids(12), run_filter("..13")
    assert_equal request_ids(12), run_filter("..12")
    assert_equal request_ids(12, 14, 20, 24), run_filter("..25")
    assert_empty run_filter("..10")
  end

  test "...ms2" do
    assert_equal request_ids(12), run_filter("...13")
    assert_equal request_ids(12, 14, 20, 24), run_filter("...25")
    assert_empty run_filter("...12")
  end

  test "ms1.." do
    assert_equal request_ids(468), run_filter("467..")
    assert_equal request_ids(468), run_filter("468..")
    assert_equal request_ids(33, 468), run_filter("30..")
    assert_empty run_filter("469..")
  end

  test "ms,delta" do
    assert_empty run_filter("24,0")
    assert_equal request_ids(24), run_filter("24,1")
    assert_equal request_ids(24), run_filter("24,3")
    assert_equal request_ids(20, 24), run_filter("24,4")
    assert_equal request_ids(20, 24), run_filter("24,9")
    assert_equal request_ids(14, 20, 24, 33), run_filter("24,10")
  end
end
