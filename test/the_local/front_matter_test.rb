# frozen_string_literal: true

require "test_helper"
require "the_local/front_matter"

module TheLocal
  class FrontMatterTest < Minitest::Test
    def test_reads_the_scope
      markdown = "---\nname: demo-info\nscope: events — emitting them\n---\n\nbody\n"

      assert_equal "events — emitting them", FrontMatter.new(markdown).scope
    end
  end
end
