# frozen_string_literal: true

require "test_helper"

class HttpMethodFilterTest < Test::Unit::TestCase
  include TestUtils

  def run_filter(arg)
    super(%W[--http-method #{arg}])
  end

  setup do
    @request_ids = [
      "2ffd7a51-489c-4892-9fec-9dd6172f69e2", # [0] GET
      "64cb3ea6-fa8a-4a60-98f9-97ca9c1f7ede", # [1] POST
      "d52d405c-01c6-481e-95f7-a48265c7cd16", # [2] GET
      "86b2f5b4-206b-4798-bf9e-3952ef87ec9a", # [3] GET
      "81337fae-ad2f-49d4-b461-c442ee3fea74", # [4] POST
      "ccb5e79b-4b2a-479f-be36-df12378358ff", # [5] POST
      "52ac2db0-7e6c-4ff6-8dd7-52f0644af397"  # [6] DELETE
    ]
  end

  test "exact case insensitive match" do
    assert_equal @request_ids.values_at(0, 2, 3).sort, run_filter("GET").sort
    assert_equal @request_ids.values_at(0, 2, 3).sort, run_filter("Get").sort

    assert_empty run_filter("PATCH")
    assert_empty run_filter("GE")
  end
end
