# frozen_string_literal: true

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
  end
end
