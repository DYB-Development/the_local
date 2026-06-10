# frozen_string_literal: true

require_relative "process_rules"

module TheLocal
  # Writes the canonical develop-process rules into a host's CLAUDE.md as a
  # managed block, read at the start of every session so the host agent always
  # follows one source of truth. Re-propagated on every install/refresh. Uses
  # its own markers so it coexists with the delegation trigger in the same file.
  class ProcessDocWriter
    BEGIN_MARKER = "<!-- the_local:process:begin -->"
    END_MARKER = "<!-- the_local:process:end -->"

    def initialize(destination:, filename: "CLAUDE.md")
      @destination = destination
      @filename = filename
    end

    def block
      <<~MARKDOWN.chomp
        #{BEGIN_MARKER}
        #{ProcessRules.content}
        #{END_MARKER}
      MARKDOWN
    end
  end
end
