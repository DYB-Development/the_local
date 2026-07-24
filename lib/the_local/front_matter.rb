# frozen_string_literal: true

require "yaml"

module TheLocal
  # Reads the YAML front matter of a committed local. Install uses it to recover
  # the provider's scope for the delegation trigger, reading straight off disk
  # without loading the provider gem.
  class FrontMatter
    BLOCK = /\A---\n.*?\n---\n/m

    def initialize(text)
      @text = text
    end

    def scope
      parsed["scope"]
    end

    private

    def parsed
      matched = @text[BLOCK]
      return {} unless matched

      YAML.safe_load(matched) || {}
    end
  end
end
