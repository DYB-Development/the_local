# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "tmpdir"

module TheLocal
  class DiskProvidersTest < Minitest::Test
    def with_provider_gem(name, agent_basenames)
      Dir.mktmpdir do |dir|
        agents_dir = File.join(dir, "lib", name.tr("-", "/"), "the_local", "agents")
        FileUtils.mkdir_p(agents_dir)
        agent_basenames.each { |base| File.write(File.join(agents_dir, base), "---\nname: x\n---\n") }
        yield dir
      end
    end

    def with_root_provider_gem(agent_basenames)
      Dir.mktmpdir do |dir|
        agents_dir = File.join(dir, "the_local", "agents")
        FileUtils.mkdir_p(agents_dir)
        agent_basenames.each { |base| File.write(File.join(agents_dir, base), "---\nname: x\n---\n") }
        yield dir
      end
    end

    def test_registers_committed_agents_from_the_gem_root
      with_root_provider_gem(["foo-info.md"]) do |dir|
        registry = Registry.new
        DiskProviders.load(registry: registry, specs: [{ name: "foo", path: dir }])

        assert_equal ["foo-info"], registry.agents.map(&:qualified_name)
      end
    end

    def test_registers_a_providers_committed_agents_from_disk
      with_provider_gem("foo", ["foo-info.md"]) do |dir|
        registry = Registry.new
        DiskProviders.load(registry: registry, specs: [{ name: "foo", path: dir }])

        assert_equal ["foo-info"], registry.agents.map(&:qualified_name)
      end
    end
  end
end
