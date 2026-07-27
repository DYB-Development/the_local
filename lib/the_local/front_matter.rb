# frozen_string_literal: true

require "yaml"

module TheLocal
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
