# frozen_string_literal: true

require "test_helper"
require "the_local/format"

module TheLocal
  class FormatCheckerTest < Minitest::Test
    COMPLETE = <<~MD
      ---
      name: demo-info
      description: d
      tools: Read
      scope: s
      ---

      ## What demo is
      ## Interface
      ## How to use it
      ## Conventions
    MD

    def test_reports_a_missing_front_matter_key
      missing = COMPLETE.sub("scope: s\n", "")

      assert_includes Format.problems(missing), "missing key: scope"
    end
  end
end
