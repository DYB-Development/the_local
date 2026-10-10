# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "tmpdir"

module TheLocal
  class RefreshTest < Minitest::Test
    Dep = Struct.new(:name)
    Spec = Struct.new(:name, :full_gem_path, :runtime_dependencies) do
      def initialize(name, full_gem_path, runtime_dependencies = [])
        super
      end
    end
    FakeDefinition = Struct.new(:dependencies, :specs, :groups)

    def setup
      TheLocal.reset!
    end

    def test_call_resets_registry_so_disk_scan_is_authoritative
      TheLocal.registry.add_provider(Provider.new(gem_name: "stale", prefix: "stale", scope: nil))

      Dir.mktmpdir do |host|
        Refresh.call(destination: host, definition: FakeDefinition.new([], [], []))

        refute_includes TheLocal.registry.providers.map(&:gem_name), "stale"
      end
    end

    def test_call_installs_committed_agents_discovered_on_disk
      Dir.mktmpdir do |gem_dir|
        agents = File.join(gem_dir, "lib/widgets/the_local/agents")
        FileUtils.mkdir_p(agents)
        File.write(File.join(agents, "widgets-info.md"), "---\nname: widgets-info\ntools: Read\n---\n\nbody\n")
        definition = FakeDefinition.new([Dep.new("widgets")], [Spec.new("widgets", gem_dir)], [:default])

        Dir.mktmpdir do |host|
          Refresh.call(destination: host, definition: definition)

          assert_path_exists File.join(host, ".claude/agents/widgets-info.md")
        end
      end
    end

    def test_call_does_not_install_a_gems_own_locals_into_its_own_repo
      Dir.mktmpdir do |gem_dir|
        agents = File.join(gem_dir, "lib/widgets/the_local/agents")
        FileUtils.mkdir_p(agents)
        File.write(File.join(agents, "widgets-info.md"), "---\nname: widgets-info\ntools: Read\n---\n\nbody\n")
        definition = FakeDefinition.new([Dep.new("widgets")], [Spec.new("widgets", gem_dir)], [:default])

        Refresh.call(destination: gem_dir, definition: definition)

        refute_path_exists File.join(gem_dir, ".claude/agents/widgets-info.md")
      end
    end

    def test_call_installs_locals_of_a_gems_gemspec_runtime_dependencies
      Dir.mktmpdir do |dep_dir|
        write_widgets_agent(dep_dir)

        Dir.mktmpdir do |gem_dir|
          own_spec = Spec.new("gadgets", gem_dir, [Dep.new("widgets")])
          definition = FakeDefinition.new([Dep.new("gadgets")], [own_spec, Spec.new("widgets", dep_dir)], [:default])

          Refresh.call(destination: gem_dir, definition: definition)

          assert_path_exists File.join(gem_dir, ".claude/agents/widgets-info.md")
        end
      end
    end

    private

    def write_widgets_agent(gem_dir)
      agents = File.join(gem_dir, "lib/widgets/the_local/agents")
      FileUtils.mkdir_p(agents)
      File.write(File.join(agents, "widgets-info.md"), "---\nname: widgets-info\ntools: Read\n---\n\nbody\n")
    end
  end
end
