# frozen_string_literal: true

require "test_helper"

module TheLocal
  class AgentTest < Minitest::Test
    def build(**overrides)
      defaults = {
        provider: "keystone", name: "scaffold",
        description: "Use PROACTIVELY for UI work.",
        tools: "Read, Write, Edit", body: "You build UI.", knowledge: "API docs."
      }
      Agent.new(**defaults.merge(overrides))
    end

    def test_filename_namespaces_the_agent_under_its_provider
      assert_equal "keystone-scaffold.md", build.filename
    end
  end
end
