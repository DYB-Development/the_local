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

    def test_ignores_agents_that_are_not_the_trio
      with_agent("---\nname: demo-info\n---\n") do |root|
        File.write(File.join(root, "the_local", "agents", "demo-author-info.md"), "---\nname: x\n---\n")

        refute_includes ProviderCheck.new(root).problems.join, "author"
      end
    end

    def full(name, scope)
      "---\nname: #{name}\ndescription: d\ntools: Read\nscope: #{scope}\n---\n\n" \
        "## What demo is\n## Interface\n## How to use it\n## Conventions\n"
    end

    def declaring(manifest, interface)
      Dir.mktmpdir do |root|
        File.write(File.join(root, "demo.gemspec"), "")
        FileUtils.mkdir_p(File.join(root, "the_local", "agents"))
        File.write(File.join(root, "the_local", "interface.yml"), manifest)
        File.write(File.join(root, "the_local", "agents", "demo-info.md"),
                   "---\nname: demo-info\ndescription: d\ntools: Read\nscope: emitting events\n---\n\n" \
                   "## What demo is\n## Interface\n#{interface}\n## How to use it\n## Conventions\n")
        yield root
      end
    end

    def test_reports_a_declared_entry_point_the_local_never_documents
      declaring("interface:\n  - Demo.emit\n  - rake demo:drain\n", "`Demo.emit`") do |root|
        assert_includes ProviderCheck.new(root).problems,
                        "demo-info.md: undocumented entry point: rake demo:drain"
      end
    end

    def test_reports_an_interface_entry_the_manifest_never_declared
      declaring("interface:\n  - Demo.emit\n", "`Demo.emit`\n`Demo::Spool.flush`") do |root|
        assert_includes ProviderCheck.new(root).problems,
                        "demo-info.md: undeclared entry point: Demo::Spool.flush"
      end
    end

    def test_reports_a_scope_that_disagrees_with_the_manifest
      declaring("scope: routing events\n", "") do |root|
        assert_includes ProviderCheck.new(root).problems,
                        "demo-info.md: scope does not match the manifest"
      end
    end

    def test_reports_when_the_trio_scopes_diverge
      Dir.mktmpdir do |root|
        File.write(File.join(root, "demo.gemspec"), "")
        agents = File.join(root, "the_local", "agents")
        FileUtils.mkdir_p(agents)
        File.write(File.join(agents, "demo-info.md"), full("demo-info", "emitting events"))
        File.write(File.join(agents, "demo-develop.md"), full("demo-develop", "routing events"))

        assert_includes ProviderCheck.new(root).problems, "the trio's scope lines diverge"
      end
    end
  end
end
