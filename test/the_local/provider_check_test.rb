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
