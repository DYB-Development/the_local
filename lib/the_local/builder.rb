# frozen_string_literal: true

require "fileutils"

module TheLocal
  # Renders each registered agent's markdown to its committed source_path, so a
  # provider gem can commit the files and the host installer later copies them
  # verbatim (rather than rendering at install time). Plain Ruby — driven by the
  # the_local:build rake task a provider runs. Agents that declared no agents_dir
  # (and so have no source_path) are skipped: there is nowhere to write them.
  class Builder
    # A real placeholder is a line-leading "TODO:"; an inline mention of the
    # marker (a guide documenting the convention) is left alone.
    PLACEHOLDER = /^\s*TODO:/

    # The canonical sections every guide must carry, so a consuming agent meets
    # the same shape in every gem's local. Matched as header prefixes.
    REQUIRED_SECTIONS = ["### Interface", "### Install", "### Conventions"].freeze

    def initialize(registry:, validate: false)
      @registry = registry
      @validate = validate
    end

    def call
      validate! if @validate

      buildable_agents.map do |agent|
        FileUtils.mkdir_p(File.dirname(agent.source_path))
        File.write(agent.source_path, agent.to_markdown)
        agent.source_path
      end
    end

    private

    def validate!
      problems = buildable_agents.flat_map { |agent| problems_for(agent) }
      return if problems.empty?

      raise Error, "the_local: incomplete guide(s):\n- #{problems.join("\n- ")}"
    end

    def problems_for(agent)
      markdown = agent.to_markdown
      problems = []
      problems << "#{agent.qualified_name}: TODO: placeholders remain" if markdown.match?(PLACEHOLDER)
      missing = REQUIRED_SECTIONS.reject { |section| markdown.include?(section) }
      problems << "#{agent.qualified_name}: missing #{missing.join(", ")}" if missing.any?
      problems
    end

    def buildable_agents
      @registry.agents.select(&:source_path)
    end
  end
end
