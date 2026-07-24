# frozen_string_literal: true

require "yaml"

module TheLocal
  # A provider's the_local/guide.md: authored front-matter describing its locals,
  # above the reference prose embedded into every rendered local as knowledge.
  class Guide
    FRONT_MATTER = /\A---\n.*?\n---\n/m

    def initialize(text)
      @text = text
    end

    def prose
      @text.sub(FRONT_MATTER, "").strip
    end

    def scope
      front_matter["scope"]
    end

    private

    def front_matter
      matched = @text[FRONT_MATTER]
      return {} unless matched

      YAML.safe_load(matched) || {}
    end
  end
end
