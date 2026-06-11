# frozen_string_literal: true

module TheLocal
  # Discovers providers by reading their committed agent files straight from each
  # bundled gem's path on disk — no gem code is loaded and no register block runs.
  # The committed .md (the build-and-commit artifact) is the declarative contract;
  # a provider contributes simply by shipping those files. Populates the same
  # registry the install pipeline already reads, so Installer/TriggerWriter/Sync
  # are unchanged.
  module DiskProviders
    AGENTS_GLOB = File.join("lib", "**", "the_local", "agents", "*.md")

    def self.load(registry:, specs:)
      specs.each { |spec| register(registry, spec) }
    end

    def self.register(registry, spec)
      files = Dir.glob(File.join(spec[:path], AGENTS_GLOB))
      return if files.empty?

      agents = files.map { |file| agent_from(spec[:name], file) }
      registry.add_provider(Provider.new(gem_name: spec[:name], prefix: agents.first.prefix, scope: nil))
      agents.each { |agent| registry.add(agent) }
    end

    def self.agent_from(gem_name, file)
      prefix, _, name = File.basename(file, ".md").rpartition("-")
      Agent.new(gem_name: gem_name, prefix: prefix, name: name,
                description: nil, tools: nil, body: nil, knowledge: nil, source_path: file)
    end
  end
end
