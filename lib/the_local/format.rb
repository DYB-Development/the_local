# frozen_string_literal: true

module TheLocal
  # The fixed shape every committed local shares, regardless of which gem it
  # documents or which creator agent authored it. The renderer is gone; this is
  # the contract that keeps the trio consistent — checked for structure, never
  # for content.
  module Format
    FRONT_MATTER_KEYS = %w[name description tools scope].freeze

    # Header prefixes, so "## What event_engine is" satisfies "## What". Every
    # local answers the same four questions in the same order: what it is,
    # the interface, how to use it, the conventions.
    SECTIONS = ["## What", "## Interface", "## How to use it", "## Conventions"].freeze

    def self.problems(markdown)
      missing_keys(markdown) + missing_sections(markdown)
    end

    def self.missing_keys(markdown)
      FRONT_MATTER_KEYS.reject { |key| markdown.match?(/^#{key}:/) }
                       .map { |key| "missing key: #{key}" }
    end

    def self.missing_sections(markdown)
      SECTIONS.reject { |section| markdown.include?(section) }
              .map { |section| "missing section: #{section}" }
    end
  end
end
