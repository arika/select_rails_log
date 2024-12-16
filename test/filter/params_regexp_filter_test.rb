# frozen_string_literal: true

require "test_helper"

class ParamsRegexpFilterTest < Test::Unit::TestCase
  include TestUtils

  def run_filter(arg)
    super(["--params-regexp", arg])
  end

  setup do
    @request_ids = [
      # [0] -
      "2ffd7a51-489c-4892-9fec-9dd6172f69e2",
      # [1] {"authenticity_token"=>"[FILTERED]", "session"=>{"email"=>"test@example.com",
      #      "password"=>"[FILTERED]", "remember_me"=>"0"}, "commit"=>"Log in"}
      "64cb3ea6-fa8a-4a60-98f9-97ca9c1f7ede",
      # [2] {"id"=>"1"}
      "d52d405c-01c6-481e-95f7-a48265c7cd16",
      # [3] -
      "86b2f5b4-206b-4798-bf9e-3952ef87ec9a",
      # [4] {"authenticity_token"=>"[FILTERED]", "micropost"=>{"content"=>"test"}, "commit"=>"Post"}
      "81337fae-ad2f-49d4-b461-c442ee3fea74",
      # [5] {"authenticity_token"=>"[FILTERED]",
      #      "micropost"=>{"content"=>"test", "image"=>#<ActionDispatch::Http::UploadedFile:0x000000010fcf7ff0 ...>},
      #      "commit"=>"Post"}
      "ccb5e79b-4b2a-479f-be36-df12378358ff",
      # [6] -
      "52ac2db0-7e6c-4ff6-8dd7-52f0644af397"
    ]
  end

  test "match with Parameters" do
    assert_equal @request_ids.values_at(1, 2, 4, 5).sort, run_filter(".").sort
    assert_equal @request_ids.values_at(1, 2, 4, 5).sort, run_filter("").sort
    assert_equal @request_ids.values_at(4, 5).sort, run_filter("FILTERED.*Post").sort
  end
end
