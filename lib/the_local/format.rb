# frozen_string_literal: true

module TheLocal
  module Format
    FRONT_MATTER_KEYS = %w[name description tools scope].freeze

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
