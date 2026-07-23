# frozen_string_literal: true

require "test_helper"

module TheLocal
  class RegistryTest < Minitest::Test
    def setup
      TheLocal.reset!
    end

    def agent(name:, gem_name: "keystone_ui", prefix: "keystone", knowledge: nil)
      Agent.new(gem_name: gem_name, prefix: prefix, name: name, description: "…",
                tools: "Read", body: "…", knowledge: knowledge, source_path: nil)
    end

    def test_add_collects_the_agent
      TheLocal.registry.add(agent(name: "scaffold"))

      assert_equal ["keystone-scaffold.md"], TheLocal.registry.agents.map(&:filename)
    end

    def test_add_accumulates_agents_across_providers
      TheLocal.registry.add(agent(name: "scaffold"))
      TheLocal.registry.add(agent(name: "define", gem_name: "event_engine", prefix: "event_engine"))

      assert_equal ["keystone-scaffold.md", "event_engine-define.md"],
                   TheLocal.registry.agents.map(&:filename)
    end

    def test_add_provider_collects_the_provider
      TheLocal.registry.add_provider(Provider.new(gem_name: "keystone_ui", prefix: "keystone", scope: "UI"))

      assert_equal ["keystone_ui"], TheLocal.registry.providers.map(&:gem_name)
    end

    def test_clear_empties_agents_and_providers
      TheLocal.registry.add(agent(name: "scaffold"))
      TheLocal.registry.add_provider(Provider.new(gem_name: "keystone_ui", prefix: "keystone", scope: nil))
      TheLocal.reset!

      assert_empty TheLocal.registry.agents
    end
  end
end
