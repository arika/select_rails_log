# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class SelectRailsLogTest < Test::Unit::TestCase
  include TestUtils

  test "--version" do
    output = StringIO.new
    assert select_rails_log(args: %w[--version], output:)
    assert output.string.start_with?("select_rails_log #{SelectRailsLog::VERSION}\n")
  end

  test "--help" do
    output = StringIO.new
    assert select_rails_log(args: %w[--help], output:)
    assert_match(/Usage: \S+ \[options\] \[logfiles\.\.\.\]\n/, output.string)
  end

  test "output to file" do
    log = File.read("#{__dir__}/data/simple.log")

    input = StringIO.new(log)
    output = StringIO.new
    select_rails_log(input:, output:)

    input.rewind
    Dir.mktmpdir do |dir|
      select_rails_log(input:, args: %W[-O #{dir}/output.txt])
      assert_equal output.string, File.read("#{dir}/output.txt")
    end
  end

  test "output to directory" do
    log = File.read("#{__dir__}/data/simple.log")

    input = StringIO.new(log)
    output = StringIO.new
    select_rails_log(input:, output:)

    input.rewind
    Dir.mktmpdir do |dir|
      select_rails_log(input:, args: %W[-O #{dir}/output/])

      assert_equal output.string, %w[
        20241215-224007.689566_2ffd7a51-489c-4892-9fec-9dd6172f69e2
        20241215-224016.522651_64cb3ea6-fa8a-4a60-98f9-97ca9c1f7ede
        20241215-224017.009694_d52d405c-01c6-481e-95f7-a48265c7cd16
        20241215-224056.912283_86b2f5b4-206b-4798-bf9e-3952ef87ec9a
        20241215-224114.717098_81337fae-ad2f-49d4-b461-c442ee3fea74
        20241215-224212.338460_ccb5e79b-4b2a-479f-be36-df12378358ff
        20241215-224222.232758_52ac2db0-7e6c-4ff6-8dd7-52f0644af397
      ].map { File.read("#{dir}/output/#{_1}.txt") }.join("\n")
    end
  end
end
