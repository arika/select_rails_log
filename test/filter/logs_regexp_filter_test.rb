# frozen_string_literal: true

require "test_helper"

class LogRegexpFilterTest < Test::Unit::TestCase
  include TestUtils

  def run_filter(arg)
    super(["--logs-regexp", arg])
  end

  setup do
    @request_ids = [
      "2ffd7a51-489c-4892-9fec-9dd6172f69e2", # [0] SessionsController#new
      "64cb3ea6-fa8a-4a60-98f9-97ca9c1f7ede", # [1] SessionsController#create
      "d52d405c-01c6-481e-95f7-a48265c7cd16", # [2] UsersController#show
      "86b2f5b4-206b-4798-bf9e-3952ef87ec9a", # [3] StaticPagesController#home
      "81337fae-ad2f-49d4-b461-c442ee3fea74", # [4] MicropostsController#create
      "ccb5e79b-4b2a-479f-be36-df12378358ff", # [5] FooBar::MicropostsController#create
      "52ac2db0-7e6c-4ff6-8dd7-52f0644af397"  # [6] SessionsController#destroy
    ]
  end

  test "match with message" do
    assert_equal [@request_ids[2]], run_filter("^  Rendering users/show.html.erb within layouts/application")
    assert_equal [@request_ids[6]], run_filter("Started DELETE")
    assert_equal [@request_ids[6]], run_filter("Completed 303")
    assert_equal [@request_ids[6]], run_filter("Started DELETE|Completed 303")
  end

  test "not match with multiple messages" do
    assert_empty run_filter("Started DELETE.*Completed 303")
  end

  test "not match with time, pid, severity, request_id" do
    assert_empty run_filter(Regexp.quote("[2024-12-15T"))
    assert_empty run_filter(Regexp.quote("#48158"))
    assert_empty run_filter(Regexp.quote("DEBUG"))
    assert_empty run_filter(Regexp.quote(@request_ids[0]))
  end

  test "not match with ANSI escape sequence" do
    assert_empty run_filter(Regexp.quote("\e[0m"))
  end
end
