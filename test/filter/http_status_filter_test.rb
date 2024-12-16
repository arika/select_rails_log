# frozen_string_literal: true

require "test_helper"

class HttpStatusFilterTest < Test::Unit::TestCase
  include TestUtils

  def run_filter(arg)
    super(%W[--http-statuses #{arg}])
  end

  setup do
    @request_ids = [
      "2ffd7a51-489c-4892-9fec-9dd6172f69e2", # [0] 200
      "64cb3ea6-fa8a-4a60-98f9-97ca9c1f7ede", # [1] 302
      "d52d405c-01c6-481e-95f7-a48265c7cd16", # [2] 200
      "86b2f5b4-206b-4798-bf9e-3952ef87ec9a", # [3] 200
      "81337fae-ad2f-49d4-b461-c442ee3fea74", # [4] 302
      "ccb5e79b-4b2a-479f-be36-df12378358ff", # [5] 302
      "52ac2db0-7e6c-4ff6-8dd7-52f0644af397"  # [6] 303
    ]
  end

  test "simple case" do
    assert_equal @request_ids.values_at(0, 2, 3).sort, run_filter("200").sort
    assert_equal @request_ids.values_at(0, 2, 3, 6).sort, run_filter("200,303").sort
    assert_equal @request_ids.values_at(0, 2, 3).sort, run_filter("200,404").sort

    assert_empty run_filter("404")
  end

  test "partial match" do
    assert_equal @request_ids.values_at(0, 2, 3).sort, run_filter("2").sort
    assert_equal @request_ids.values_at(0, 2, 3).sort, run_filter("20").sort
    assert_equal @request_ids.values_at(1, 4, 5, 6).sort, run_filter("3").sort
    assert_equal @request_ids.values_at(0, 2, 3).sort, run_filter("2,4").sort

    assert_empty run_filter("4")
    assert_empty run_filter("00")
  end

  test "negative case" do
    assert_equal @request_ids.values_at(1, 4, 5, 6).sort, run_filter("!200").sort
    assert_equal @request_ids.values_at(1, 4, 5).sort, run_filter("!200,303").sort
    assert_equal @request_ids.values_at(0, 2, 3, 6).sort, run_filter("2,3,!302").sort
    assert_equal @request_ids.values_at(0, 2, 3).sort, run_filter("2,3,!30").sort
  end
end
