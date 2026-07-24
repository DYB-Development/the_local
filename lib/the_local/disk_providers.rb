# frozen_string_literal: true

require_relative "agent"
require_relative "front_matter"
require_relative "registry"

module TheLocal
  # Discovers providers by reading their committed agent files straight from each
  # bundled gem's path on disk — no gem code is loaded and no register block runs.
  # The committed .md (the build-and-commit artifact) is the declarative contract;
  # a provider contributes simply by shipping those files. Populates the same
  # registry the install pipeline already reads, so Installer/TriggerWriter/Sync
  # are unchanged.
  module DiskProviders
    AGENTS_GLOB = File.join("the_local", "agents", "*.md")
    LEGACY_AGENTS_GLOB = File.join("lib", "**", "the_local", "agents", "*.md")

    def self.load(registry:, specs:)
      specs.each { |spec| register(registry, spec) }
    end

    def self.agent_files(path)
      rendered = Dir.glob(File.join(path, AGENTS_GLOB))
      rendered.any? ? rendered : Dir.glob(File.join(path, LEGACY_AGENTS_GLOB))
    end

    def self.register(registry, spec)
      files = agent_files(spec[:path])
      return if files.empty?

      agents = files.map { |file| agent_from(spec[:name], file) }
      registry.add_provider(
        Provider.new(gem_name: spec[:name], prefix: agents.first.prefix, scope: agents.first.scope)
      )
      agents.each { |agent| registry.add(agent) }
    end

    def self.agent_from(gem_name, file)
      prefix, _, name = File.basename(file, ".md").rpartition("-")
      Agent.new(gem_name: gem_name, prefix: prefix, name: name,
                description: nil, tools: nil, body: nil, knowledge: nil, source_path: file,
                scope: FrontMatter.new(File.read(file)).scope)
    end
  end
end
