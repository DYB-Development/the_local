# frozen_string_literal: true

require "test_helper"
require "the_local/builder"
require "tmpdir"

module TheLocal
  class SyncTest < Minitest::Test
    def setup
      TheLocal.reset!
    end

    def register_keystone(agents_dir:)
      TheLocal.registry.add_provider(Provider.new(gem_name: "keystone_ui", prefix: "keystone", scope: "UI work"))
      TheLocal.registry.add(
        Agent.new(gem_name: "keystone_ui", prefix: "keystone", name: "develop",
                  description: "Build UI.", tools: "Read, Write, Edit", body: "…", knowledge: "API.",
                  source_path: File.join(agents_dir, "keystone-develop.md"))
      )
      Builder.new(registry: TheLocal.registry).call
    end

    def sync_into(dir, direct: ["keystone_ui"], bundled: ["keystone_ui"])
      Sync.new(registry: TheLocal.registry, destination: dir,
               direct_dependencies: direct, bundled_gems: bundled).call
    end

    def test_writes_agents_and_the_trigger_for_allowed_gems
      Dir.mktmpdir do |gem_dir|
        register_keystone(agents_dir: gem_dir)

        Dir.mktmpdir do |dir|
          sync_into(dir)

          assert_path_exists File.join(dir, ".claude/agents/keystone-develop.md")
          assert_path_exists File.join(dir, "CLAUDE.md")
        end
      end
    end
  end
end
