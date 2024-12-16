# frozen_string_literal: true

require "test_helper"
require "csv"

class TsvPrinterTest < Test::Unit::TestCase
  include TestUtils

  setup do
    @log = File.read("#{__dir__}/../data/simple.log")
  end

  test "print in tsv format" do
    input = StringIO.new(@log)
    output = StringIO.new
    assert select_rails_log(args: %w[--tsv], input:, output:)

    rows = []
    CSV.parse(output.string, col_sep: "\t", headers: true) do |row|
      rows << row.to_h.values_at("started", "request_id", "controller_action",
                                 "http_status", "http_method", "path",
                                 "total_duration", "active_record_duration", "views_duration", "allocations")
    end
    assert_equal(
      [
        ["2024-12-15 22:40:07.689566", "2ffd7a51-489c-4892-9fec-9dd6172f69e2",
         "SessionsController#new", "200", "GET", "/login", "24", "0.0", "21.9", "9931"],
        ["2024-12-15 22:40:16.522651", "64cb3ea6-fa8a-4a60-98f9-97ca9c1f7ede",
         "SessionsController#create", "302", "POST", "/login", "468", "1.8", nil, "3301"],
        ["2024-12-15 22:40:17.009694", "d52d405c-01c6-481e-95f7-a48265c7cd16",
         "UsersController#show", "200", "GET", "/users/1", "14", "0.4", "12.4", "23176"],
        ["2024-12-15 22:40:56.912283", "86b2f5b4-206b-4798-bf9e-3952ef87ec9a",
         "StaticPagesController#home", "200", "GET", "/", "33", "0.8", "17.8", "18877"],
        ["2024-12-15 22:41:14.717098", "81337fae-ad2f-49d4-b461-c442ee3fea74",
         "MicropostsController#create", "302", "POST", "/microposts", "14", "3.4", nil, "4535"],
        ["2024-12-15 22:42:12.338460", "ccb5e79b-4b2a-479f-be36-df12378358ff",
         "FooBar::MicropostsController#create", "302", "POST", "/foo_bar/microposts", "20", "1.8", nil, "8385"],
        ["2024-12-15 22:42:22.232758", "52ac2db0-7e6c-4ff6-8dd7-52f0644af397",
         "SessionsController#destroy", "303", "DELETE", "/logout", "12", "3.2", nil, "3344"]
      ],
      rows
    )
  end
end
