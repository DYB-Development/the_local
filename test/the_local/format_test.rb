# frozen_string_literal: true

require "test_helper"
require "the_local/format"

module TheLocal
  class FormatTest < Minitest::Test
    def test_lists_the_required_front_matter_keys
      assert_equal %w[name description tools scope], Format::FRONT_MATTER_KEYS
    end
  end
end
