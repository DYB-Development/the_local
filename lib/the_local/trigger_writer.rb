# frozen_string_literal: true

module TheLocal
  # Writes the mandatory delegation trigger — the standing rule, read at the
  # start of every session, that tells the host agent to delegate to its locals
  # rather than work from memory. Generated from the registry's providers,
  # filtered to the host's allowed gems. Plain Ruby; the Rails generator wraps it.
  class TriggerWriter
    BEGIN_MARKER = "<!-- the_local:begin -->"
    END_MARKER = "<!-- the_local:end -->"

    def initialize(registry:, destination:, allowed_gems:, filename: "CLAUDE.md")
      @registry = registry
      @destination = destination
      @allowed_gems = allowed_gems
      @filename = filename
    end

    def call
      path = File.join(@destination, @filename)
      existing = File.exist?(path) ? File.read(path) : ""
      File.write(path, "#{merge(existing).chomp}\n")
    end

    def rule
      <<~MARKDOWN.chomp
        #{BEGIN_MARKER}
        ## Delegate to your locals

        This project has installed expert subagents. Before doing any work, read the
        agents' descriptions. When an expert owns the work, delegate it to that expert.
        Never do work an expert owns yourself, and never do it from memory.
        #{END_MARKER}
      MARKDOWN
    end

    private

    # Replaces an existing marked section in place, or appends one, so re-running
    # re-syncs the rule without duplicating or clobbering the host's own content.
    def merge(existing)
      section = /#{Regexp.escape(BEGIN_MARKER)}.*?#{Regexp.escape(END_MARKER)}/m
      return existing.sub(section, rule) if existing.match?(section)
      return rule if existing.strip.empty?

      "#{existing.chomp}\n\n#{rule}"
    end
  end
end
