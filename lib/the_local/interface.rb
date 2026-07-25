# frozen_string_literal: true

require "yaml"

module TheLocal
  class Interface
    FILE = File.join("the_local", "interface.yml")

    def self.at(gem_root)
      path = File.join(gem_root, FILE)
      new(File.exist?(path) ? YAML.safe_load_file(path) : nil)
    end

    def initialize(declaration)
      @declaration = declaration || {}
    end

    def scope
      @declaration["scope"]
    end

    def entry_points_for(facet)
      @declaration[facet] || []
    end
  end
end
