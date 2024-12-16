# frozen_string_literal: true

require "test_helper"

class NullPrinterTest < Test::Unit::TestCase
  include TestUtils

  setup do
    @log = File.read("#{__dir__}/../data/simple.log")
  end

  test "print nothing" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--no-output], input:, output:)

    assert_equal "", output.string
  end
end
