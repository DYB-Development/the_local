# frozen_string_literal: true

require "test_helper"
require "the_local/builder"
require "tmpdir"

module TheLocal
  class InstallerTest < Minitest::Test
    def setup
      TheLocal.reset!
    end

    def add_agent(name, gem_name: "keystone_ui", prefix: "keystone", agents_dir: nil)
      source_path = agents_dir && File.join(agents_dir, "#{prefix}-#{name}.md")
      TheLocal.registry.add(
        Agent.new(gem_name: gem_name, prefix: prefix, name: name,
                  description: "Use PROACTIVELY for UI.", tools: "Read, Write, Edit",
                  body: "You build UI.", knowledge: "API docs.", source_path: source_path)
      )
    end

    def build_keystone(agents_dir:, names: %w[scaffold])
      names.each { |name| add_agent(name, agents_dir: agents_dir) }
      Builder.new(registry: TheLocal.registry).call
    end

    def install_into(dir, allowed_gems: ["keystone_ui"])
      Installer.new(registry: TheLocal.registry, destination: dir, allowed_gems: allowed_gems).call
    end

    def test_copies_the_committed_agent_file_verbatim
      Dir.mktmpdir do |gem_dir|
        build_keystone(agents_dir: gem_dir)
        File.write(TheLocal.registry.agents.first.source_path, "SHIPPED BY THE GEM")

        Dir.mktmpdir do |dir|
          install_into(dir)

          assert_equal "SHIPPED BY THE GEM", File.read(File.join(dir, ".claude/agents/keystone-scaffold.md"))
        end
      end
    end

    def test_skips_providers_outside_the_allowed_gems
      Dir.mktmpdir do |gem_dir|
        build_keystone(agents_dir: gem_dir)
        add_agent("helper", gem_name: "some_transitive_gem", prefix: "some_transitive_gem")

        Dir.mktmpdir do |dir|
          install_into(dir, allowed_gems: ["keystone_ui"])

          refute_path_exists File.join(dir, ".claude/agents/some_transitive_gem-helper.md")
        end
      end
    end

    def test_raises_an_actionable_error_when_an_allowed_agent_has_no_committed_file
      add_agent("scaffold", agents_dir: nil)

      Dir.mktmpdir do |dir|
        error = assert_raises(TheLocal::Error) { install_into(dir) }

        assert_match(/keystone-scaffold/, error.message)
      end
    end

    def test_writes_every_allowed_agent
      Dir.mktmpdir do |gem_dir|
        build_keystone(agents_dir: gem_dir, names: %w[scaffold review])

        Dir.mktmpdir do |dir|
          install_into(dir, allowed_gems: ["keystone_ui"])

          assert_equal %w[keystone-review.md keystone-scaffold.md],
                       Dir.children(File.join(dir, ".claude/agents")).sort
        end
      end
    end
  end
end
