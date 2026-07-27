# frozen_string_literal: true

require "test_helper"
require "the_local/format"

module TheLocal
  class FormatTest < Minitest::Test
    def test_lists_the_required_front_matter_keys
      assert_equal %w[name description tools scope], Format::FRONT_MATTER_KEYS
    end

    def test_lists_the_required_body_sections
      assert_equal ["## What", "## Interface", "## How to use it", "## Conventions"],
                   Format::SECTIONS
    end

    def test_returns_a_section_body_without_the_sections_that_follow
      markdown = "## Interface\n`Demo.emit`\n\n## How to use it\ncall it\n"

      assert_equal "`Demo.emit`", Format.section(markdown, "## Interface").strip
    end
  end
end
