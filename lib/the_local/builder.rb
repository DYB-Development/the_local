# frozen_string_literal: true

require "fileutils"

module TheLocal
  # Renders each registered agent's markdown to its committed source_path, so a
  # provider gem can commit the files and the host installer later copies them
  # verbatim (rather than rendering at install time). Plain Ruby — driven by the
  # the_local:build rake task a provider runs. Agents that declared no agents_dir
  # (and so have no source_path) are skipped: there is nowhere to write them.
  class Builder
    # A guide that still carries scaffold placeholders hasn't surfaced the gem's
    # real interface, so a host agent would have to dig into source — the exact
    # thing the_local exists to prevent. When +validate+ is on, the build refuses
    # such agents instead of shipping an incomplete local.
    TODO_MARKER = "TODO:"

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
      incomplete = buildable_agents.select { |agent| agent.to_markdown.include?(TODO_MARKER) }
      return if incomplete.empty?

      names = incomplete.map(&:qualified_name).join(", ")
      raise Error, "the_local: guide still has #{TODO_MARKER} placeholders — fill them in " \
                   "so the local surfaces the real interface (offending: #{names})"
    end

    def buildable_agents
      @registry.agents.select(&:source_path)
    end
  end
end
