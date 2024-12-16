# frozen_string_literal: true

require "test_helper"

class UnicodePlotPrinterTest < Test::Unit::TestCase
  include TestUtils

  setup do
    @log = File.read("#{__dir__}/../data/simple.log")
  end

  test "histgram" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--histgram], input:, output:)

    [
      "[  0.0, 200.0)",
      "[200.0, 400.0)",
      "[400.0, 600.0)"
    ].each do |controller_action|
      assert_includes output.string, controller_action
    end
  end

  test "boxplot" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--boxplot], input:, output:)

    %w[
      FooBar::MicropostsController#create
      MicropostsController#create
      SessionsController#create
      SessionsController#destroy
      SessionsController#new
      StaticPagesController#home
      UsersController#show
    ].each do |controller_action|
      assert_includes output.string, controller_action
    end
  end
end
