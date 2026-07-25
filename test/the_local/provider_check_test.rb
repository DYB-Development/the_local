# frozen_string_literal: true

require "test_helper"
require "the_local/provider_check"
require "fileutils"
require "tmpdir"

module TheLocal
  class ProviderCheckTest < Minitest::Test
    def with_agent(markdown)
      Dir.mktmpdir do |root|
        File.write(File.join(root, "demo.gemspec"), "")
        agents = File.join(root, "the_local", "agents")
        FileUtils.mkdir_p(agents)
        File.write(File.join(agents, "demo-info.md"), markdown)
        yield root
      end
    end

    def test_names_the_file_and_its_problem
      with_agent("---\nname: demo-info\n---\n") do |root|
        assert_includes ProviderCheck.new(root).problems, "demo-info.md: missing key: scope"
      end
    end

    def test_ignores_agents_that_are_not_a_local
      with_agent("---\nname: demo-info\n---\n") do |root|
        File.write(File.join(root, "the_local", "agents", "demo-author-info.md"), "---\nname: x\n---\n")

        refute_includes ProviderCheck.new(root).problems.join, "author"
      end
    end

    def local_documenting(local, interface, scope: "emitting events")
      "---\nname: demo-#{local}\ndescription: d\ntools: Read\nscope: #{scope}\n---\n\n" \
        "## What demo is\n## Interface\n#{interface}\n## How to use it\n## Conventions\n"
    end

    def declaring(manifest, interfaces)
      Dir.mktmpdir do |root|
        File.write(File.join(root, "demo.gemspec"), "")
        FileUtils.mkdir_p(File.join(root, "the_local", "agents"))
        File.write(File.join(root, "the_local", "interface.yml"), manifest)
        interfaces.each do |local, interface|
          File.write(File.join(root, "the_local", "agents", "demo-#{local}.md"),
                     local_documenting(local, interface))
        end
        yield root
      end
    end

    def test_reports_an_entry_point_its_own_local_never_documents
      declaring("info:\n  - Demo.emit\n  - rake demo:drain\n", { "info" => "- `Demo.emit`" }) do |root|
        assert_includes ProviderCheck.new(root).problems,
                        "demo-info.md: undocumented entry point: rake demo:drain"
      end
    end

    def test_reports_an_entry_point_documented_by_the_local_it_was_not_declared_for
      declaring("install:\n  - rake demo:setup\n", { "develop" => "- `rake demo:setup`" }) do |root|
        assert_includes ProviderCheck.new(root).problems,
                        "demo-develop.md: entry point declared for install: rake demo:setup"
      end
    end

    def test_reports_an_interface_entry_the_manifest_never_declared
      declaring("info:\n  - Demo.emit\n", { "info" => "- `Demo.emit`\n- `Demo::Spool.flush`" }) do |root|
        assert_includes ProviderCheck.new(root).problems,
                        "demo-info.md: undeclared entry point: Demo::Spool.flush"
      end
    end

    def test_ignores_backticked_prose_that_does_not_lead_a_bullet
      declaring("info:\n  - Demo.emit\n", { "info" => "- `Demo.emit` — writes to `log/demo.log`" }) do |root|
        refute_includes ProviderCheck.new(root).problems,
                        "demo-info.md: undeclared entry point: log/demo.log"
      end
    end

    def test_reports_a_scope_that_disagrees_with_the_manifest
      declaring("scope: routing events\n", { "info" => "" }) do |root|
        assert_includes ProviderCheck.new(root).problems,
                        "demo-info.md: scope does not match the manifest"
      end
    end

    def test_reports_when_the_locals_disagree_without_a_declared_scope
      Dir.mktmpdir do |root|
        File.write(File.join(root, "demo.gemspec"), "")
        agents = File.join(root, "the_local", "agents")
        FileUtils.mkdir_p(agents)
        File.write(File.join(agents, "demo-info.md"), local_documenting("info", "", scope: "emitting events"))
        File.write(File.join(agents, "demo-develop.md"), local_documenting("develop", "", scope: "routing events"))

        assert_includes ProviderCheck.new(root).problems, "the locals' scope lines disagree"
      end
    end
  end
end
