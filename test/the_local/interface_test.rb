# frozen_string_literal: true

require "test_helper"
require "the_local/guide"

module TheLocal
  class InterfaceTest < Minitest::Test
    def test_offers_the_standard_trio
      agents = Interface.agents(gem_name: "demo", guide: Guide.new("the guide"), agents_dir: "/agents")

      assert_equal %w[info install develop], agents.map(&:name)
    end

    def test_uses_the_authored_description
      guide = Guide.new(
        "---\nlocals:\n  develop:\n    description: Use PROACTIVELY when defining events.\n---\n\n## Demo\n"
      )

      agents = Interface.agents(gem_name: "demo", guide: guide, agents_dir: "/agents")

      assert_equal "Use PROACTIVELY when defining events.", agents.find { |agent| agent.name == "develop" }.description
    end

    def test_carries_the_authored_scope_onto_every_local
      guide = Guide.new("---\nscope: events — defining and emitting them\n---\n\n## Demo\n")

      agents = Interface.agents(gem_name: "demo", guide: guide, agents_dir: "/agents")

      assert_equal ["events — defining and emitting them"] * 3, agents.map(&:scope)
    end
  end
end
