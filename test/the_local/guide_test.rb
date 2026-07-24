# frozen_string_literal: true

require "test_helper"
require "the_local/guide"

module TheLocal
  class GuideTest < Minitest::Test
    def test_prose_excludes_the_front_matter
      guide = Guide.new("---\nscope: events\n---\n\n## Demo\n")

      assert_equal "## Demo", guide.prose
    end

    def test_reads_the_authored_scope
      guide = Guide.new("---\nscope: events — defining and emitting them\n---\n\n## Demo\n")

      assert_equal "events — defining and emitting them", guide.scope
    end

    def test_reads_an_authored_locals_description
      guide = Guide.new(
        "---\nlocals:\n  develop:\n    description: Use PROACTIVELY when defining events.\n---\n\n## Demo\n"
      )

      assert_equal "Use PROACTIVELY when defining events.", guide.local("develop")["description"]
    end
  end
end
