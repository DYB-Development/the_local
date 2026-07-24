# frozen_string_literal: true

require_relative "guide"
require_relative "interface"
require_relative "registry"
require_relative "builder"

module TheLocal
  # Renders a provider's committed agent files from its gem root, needing no
  # registration code in the gem: the gem name comes from its gemspec, the
  # knowledge from the_local/guide.md, and the agents from the standard Interface.
  class ProviderBuild
    GUIDE = File.join("the_local", "guide.md")
    AGENTS_DIR = File.join("the_local", "agents")

    def initialize(gem_root)
      @gem_root = gem_root
    end

    def agents
      Interface.agents(
        gem_name: gem_name,
        guide: Guide.new(File.read(File.join(@gem_root, GUIDE))),
        agents_dir: File.join(@gem_root, AGENTS_DIR)
      )
    end

    def call
      registry = Registry.new
      agents.each { |agent| registry.add(agent) }
      Builder.new(registry: registry, validate: true).call
    end

    private

    def gem_name
      File.basename(Dir.glob(File.join(@gem_root, "*.gemspec")).first, ".gemspec")
    end
  end
end
