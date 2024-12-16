# frozen_string_literal: true

require "test_helper"

class TimeRangeFilterTest < Test::Unit::TestCase
  include TestUtils

  def run_filter(arg)
    super(%W[--time-range #{arg}])
  end

  setup do
    @request_ids = [
      "2ffd7a51-489c-4892-9fec-9dd6172f69e2", # [0] 2024-12-15T22:40:07.689566 .. 2024-12-15T22:40:07.726132
      "64cb3ea6-fa8a-4a60-98f9-97ca9c1f7ede", # [1] 2024-12-15T22:40:16.522651 .. 2024-12-15T22:40:17.005013
      "d52d405c-01c6-481e-95f7-a48265c7cd16", # [2] 2024-12-15T22:40:17.009694 .. 2024-12-15T22:40:17.027046
      "86b2f5b4-206b-4798-bf9e-3952ef87ec9a", # [3] 2024-12-15T22:40:56.912283 .. 2024-12-15T22:40:56.960128
      "81337fae-ad2f-49d4-b461-c442ee3fea74", # [4] 2024-12-15T22:41:14.717098 .. 2024-12-15T22:41:14.744251
      "ccb5e79b-4b2a-479f-be36-df12378358ff", # [5] 2024-12-15T22:42:12.338460 .. 2024-12-15T22:42:12.376636
      "52ac2db0-7e6c-4ff6-8dd7-52f0644af397"  # [6] 2024-12-15T22:42:22.232758 .. 2024-12-15T22:42:22.259118
    ]
  end

  test "basic match" do
    # I, [2024-12-15T22:40:07.689566 #48158]  ... Started GET "/login" for 127.0.0.1 at 2024-12-15 22:40:07 +0900
    # I, [2024-12-15T22:40:07.702238 #48158]  ... Processing by SessionsController#new as HTML
    # ...
    # I, [2024-12-15T22:40:07.726132 #48158]  ... Completed 200 OK in 24ms

    assert_equal [@request_ids[0]], run_filter("2024-12-15T22:40:07.689566..2024-12-15T22:40:07.689566")
    assert_equal [@request_ids[0]], run_filter("2024-12-15T22:40:07.726132..2024-12-15T22:40:07.726132")
    assert_equal [@request_ids[0]], run_filter("2024-12-15T22:40:07.689565..2024-12-15T22:40:07.726133")

    assert_equal [@request_ids[0]], run_filter("2024-12-15T22:40:07.689567..2024-12-15T22:40:07.726131")
    assert_equal [@request_ids[0]], run_filter("2024-12-15T22:40:07.689567..2024-12-15T22:40:07.689567")

    assert_empty run_filter("2024-12-15T22:40:07.689565..2024-12-15T22:40:07.689565")
    assert_empty run_filter("2024-12-15T22:40:07.726133..2024-12-15T22:40:07.726133")
  end

  test "time1..time2" do
    assert_empty run_filter("2024-12-15T22:40:07..2024-12-15T22:40:07")
    assert_equal [@request_ids[0]], run_filter("2024-12-15T22:40:07..2024-12-15T22:40:08")
  end

  test "time1...time2" do
    assert_empty run_filter("2024-12-15T22:40:07...2024-12-15T22:40:07")
    assert_equal [@request_ids[0]], run_filter("2024-12-15T22:40:07...2024-12-15T22:40:08")
  end

  test "..time2" do
    assert_empty run_filter("..2024-12-15T22:40:07")
    assert_equal [@request_ids[0]], run_filter("..2024-12-15T22:40:08")
  end

  test "...time2" do
    assert_empty run_filter("...2024-12-15T22:40:07")
    assert_equal [@request_ids[0]], run_filter("...2024-12-15T22:40:08")
  end

  test "time1.." do
    assert_empty run_filter("2024-12-15T22:42:23..")
    assert_equal [@request_ids[6]], run_filter("2024-12-15T22:42:22..")
  end

  test "time,seconds" do
    assert_empty run_filter("2024-12-15T22:40:56,0")
    assert_equal [@request_ids[3]], run_filter("2024-12-15T22:40:56.912283,0")
    assert_equal [@request_ids[3]], run_filter("2024-12-15T22:40:56,1")
    assert_equal [@request_ids[3]], run_filter("2024-12-15T22:40:56,18")
    assert_equal [@request_ids[3], @request_ids[4]], run_filter("2024-12-15T22:40:56,19")
  end
end
