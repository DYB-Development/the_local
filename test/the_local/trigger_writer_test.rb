# frozen_string_literal: true

require "test_helper"
require "tmpdir"

module TheLocal
  class TriggerWriterTest < Minitest::Test
    def setup
      TheLocal.reset!
    end

    def register_keystone
      TheLocal.registry.add_provider(
        Provider.new(gem_name: "keystone_ui", prefix: "keystone", scope: "UI — pages, forms, tables")
      )
    end

    def writer(dir, allowed_gems: ["keystone_ui"])
      TriggerWriter.new(registry: TheLocal.registry, destination: dir, allowed_gems: allowed_gems)
    end

    def test_rule_names_no_gem_and_repeats_no_scope
      register_keystone

      Dir.mktmpdir do |dir|
        rule = writer(dir).rule

        assert_equal [false, false, false],
                     [rule.include?("UI — pages, forms, tables"), rule.include?("keystone"), rule.include?("→")]
      end
    end

    def test_rule_excludes_providers_outside_the_allowed_gems
      register_keystone
      TheLocal.registry.add_provider(
        Provider.new(gem_name: "some_transitive_gem", prefix: "some_transitive_gem", scope: "internal")
      )

      Dir.mktmpdir do |dir|
        refute_includes writer(dir, allowed_gems: ["keystone_ui"]).rule, "some_transitive_gem"
      end
    end

    def test_call_creates_claude_md_with_the_rule_when_absent
      register_keystone

      Dir.mktmpdir do |dir|
        writer(dir).call

        assert_equal "#{writer(dir).rule}\n", File.read(File.join(dir, "CLAUDE.md"))
      end
    end

    def test_call_is_idempotent_across_reruns
      register_keystone

      Dir.mktmpdir do |dir|
        writer(dir).call
        writer(dir).call

        assert_equal 1, File.read(File.join(dir, "CLAUDE.md")).scan(TriggerWriter::BEGIN_MARKER).size
      end
    end

    def test_call_leaves_the_file_byte_identical_across_reruns
      register_keystone

      Dir.mktmpdir do |dir|
        path = File.join(dir, "CLAUDE.md")
        writer(dir).call
        after_first_run = File.read(path)
        writer(dir).call

        assert_equal after_first_run, File.read(path)
      end
    end

    def test_call_preserves_existing_claude_md_content
      register_keystone

      Dir.mktmpdir do |dir|
        path = File.join(dir, "CLAUDE.md")
        File.write(path, "# My App\n\nHouse rules.\n")
        writer(dir).call

        assert File.read(path).start_with?("# My App\n\nHouse rules.")
      end
    end

    def test_call_replaces_an_older_long_delegation_list_in_place
      register_keystone

      Dir.mktmpdir do |dir|
        path = File.join(dir, "CLAUDE.md")
        old_list = "## Delegate to your locals\n\n- UI — pages, forms, tables → keystone-* agents"
        old_section = "#{TriggerWriter::BEGIN_MARKER}\n#{old_list}\n#{TriggerWriter::END_MARKER}"
        File.write(path, "# My App\n\n#{old_section}\n\nHouse rules.\n")
        writer(dir).call

        assert_equal "# My App\n\n#{writer(dir).rule}\n\nHouse rules.\n", File.read(path)
      end
    end

    def test_rule_tells_a_session_to_find_the_owning_agent_by_its_description
      Dir.mktmpdir do |dir|
        assert_includes writer(dir).rule, "read the\nagents' descriptions"
      end
    end

    def test_rule_forbids_a_session_from_doing_an_experts_work_itself
      Dir.mktmpdir do |dir|
        assert_includes writer(dir).rule, "Never do work an expert owns yourself, and never do it from memory."
      end
    end
  end
end
