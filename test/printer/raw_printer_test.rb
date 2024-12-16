# frozen_string_literal: true

require "test_helper"

class RawPrinterTest < Test::Unit::TestCase
  include TestUtils

  setup do
    @log = File.read("#{__dir__}/../data/overlapped.log")
  end

  test "print nothing" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--raw], input:, output:)

    lines = @log.lines
    expected = %w[
      5989416a-5d9a-49b1-92e5-54ef00e0e38c
      88a6d51e-f6cd-4969-bdc9-f2cebdfbea98
      06df5c81-c6dc-48f2-957c-7550a854ad00
    ].flat_map { |request_id| lines.select { |line| line.include?(request_id) } }.join
    assert_equal expected, output.string
  end

  test "exclude deubg" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--raw --exclude-debug-logs], input:, output:)

    lines = @log.lines
    expected = %w[
      5989416a-5d9a-49b1-92e5-54ef00e0e38c
      88a6d51e-f6cd-4969-bdc9-f2cebdfbea98
      06df5c81-c6dc-48f2-957c-7550a854ad00
    ].flat_map do |request_id|
      lines.select { |line| !line.start_with?("D,") && line.include?(request_id) }
    end.join
    assert_equal expected, output.string
  end
end
