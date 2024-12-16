# frozen_string_literal: true

require "test_helper"

class ControllerActionFilterTest < Test::Unit::TestCase
  include TestUtils

  def run_filter(arg)
    super(%W[--controller-action #{arg}]).sort
  end

  def request_ids(*names)
    @request_ids.filter_map { |n, request_id| names.include?(n) ? request_id : nil }.sort
  end

  setup do
    @request_ids = [
      # [controller#action, request_id]
      %w[SessionsController#new 2ffd7a51-489c-4892-9fec-9dd6172f69e2],
      %w[SessionsController#create 64cb3ea6-fa8a-4a60-98f9-97ca9c1f7ede],
      %w[UsersController#show d52d405c-01c6-481e-95f7-a48265c7cd16],
      %w[StaticPagesController#home 86b2f5b4-206b-4798-bf9e-3952ef87ec9a],
      %w[MicropostsController#create 81337fae-ad2f-49d4-b461-c442ee3fea74],
      %w[FooBar::MicropostsController#create ccb5e79b-4b2a-479f-be36-df12378358ff],
      %w[SessionsController#destroy 52ac2db0-7e6c-4ff6-8dd7-52f0644af397]
    ]
  end

  test "controller name and action name" do
    assert_equal request_ids("UsersController#show"), run_filter("UsersController#show")
    assert_equal request_ids("UsersController#show"), run_filter("users#show")

    assert_equal request_ids("MicropostsController#create"), run_filter("MicropostsController#create")
    assert_equal request_ids("MicropostsController#create"), run_filter("microposts#create")

    assert_equal request_ids("FooBar::MicropostsController#create"), run_filter("FooBar::MicropostsController#create")
    assert_equal request_ids("FooBar::MicropostsController#create"), run_filter("foo_bar/microposts#create")
  end

  test "controller name only" do
    assert_equal request_ids("SessionsController#new", "SessionsController#create", "SessionsController#destroy"),
                 run_filter("SessionsController")
    assert_equal request_ids("SessionsController#new", "SessionsController#create", "SessionsController#destroy"),
                 run_filter("sessions")

    assert_equal request_ids("MicropostsController#create"), run_filter("MicropostsController")
    assert_equal request_ids("MicropostsController#create"), run_filter("microposts")

    assert_equal request_ids("FooBar::MicropostsController#create"), run_filter("FooBar::MicropostsController")
    assert_equal request_ids("FooBar::MicropostsController#create"), run_filter("foo_bar/microposts")
  end

  test "multiple names" do
    assert_equal request_ids("UsersController#show", "MicropostsController#create"),
                 run_filter("users,MicropostsController#create")
  end
end
