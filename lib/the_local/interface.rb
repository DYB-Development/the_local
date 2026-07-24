# frozen_string_literal: true

require_relative "agent"

module TheLocal
  # The standard command interface every provider exposes to a host: `info`
  # (read-only explainer), `install` (sets the gem up), and `develop` (the
  # proactive domain worker). the_local renders these from the provider's guide,
  # so a provider gem carries no registration code of its own.
  module Interface
    Facet = Data.define(:name, :description, :tools, :body)

    FACETS = [
      Facet.new(
        name: "info",
        description: "Use to learn what %<gem>s offers — its API and conventions.",
        tools: "Read",
        body: "You explain what %<gem>s does and how to use it, answering only from " \
              "your reference. You make no changes, and you never read %<gem>s's " \
              "source — the reference is the complete interface."
      ),
      Facet.new(
        name: "install",
        description: "Use to add %<gem>s to a project and set it up correctly.",
        tools: "Bash, Read, Edit",
        body: "You add %<gem>s to the project and complete its setup by following your " \
              "reference's Install section exactly, step by step. You do not invent steps " \
              "it does not list, and you never read %<gem>s's source."
      ),
      Facet.new(
        name: "develop",
        description: "Use PROACTIVELY for any %<gem>s work. MUST BE USED instead of " \
                     "hand-rolling it.",
        tools: "Read, Write, Edit, Grep",
        body: "You do %<gem>s work by following the Interface, Recipe, and Conventions " \
              "in your reference exactly, so usage stays consistent across the host. You " \
              "implement from the reference, never from %<gem>s's source."
      )
    ].freeze

    def self.agents(gem_name:, guide:, agents_dir:)
      FACETS.map { |facet| agent_for(facet, gem_name, guide, agents_dir) }
    end

    def self.agent_for(facet, gem_name, guide, agents_dir)
      authored = guide.local(facet.name)

      Agent.new(
        gem_name: gem_name, prefix: gem_name, name: facet.name,
        description: authored["description"] || format(facet.description, gem: gem_name),
        tools: facet.tools,
        body: authored["body"] || format(facet.body, gem: gem_name),
        knowledge: guide.prose,
        source_path: File.join(agents_dir, "#{gem_name}-#{facet.name}.md")
      )
    end
  end
end
