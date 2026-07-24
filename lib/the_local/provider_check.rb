# frozen_string_literal: true

require_relative "format"

module TheLocal
  # Verifies a provider's committed locals hold the fixed shape, without caring
  # what a creator agent wrote into them. This is what remains of the old build
  # gate once rendering is gone: structure is enforced, content is authored.
  class ProviderCheck
    AGENTS_GLOB = File.join("the_local", "agents", "*.md")

    def initialize(gem_root)
      @gem_root = gem_root
    end

    def problems
      Dir.glob(File.join(@gem_root, AGENTS_GLOB)).sort.flat_map do |file|
        Format.problems(File.read(file)).map { |problem| "#{File.basename(file)}: #{problem}" }
      end
    end
  end
end
