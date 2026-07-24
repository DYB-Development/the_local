# frozen_string_literal: true

require_relative "format"

module TheLocal
  # Verifies a provider's committed trio holds the fixed shape, without caring
  # what a creator agent wrote into it. This is what remains of the old build
  # gate once rendering is gone: structure is enforced, content is authored. Only
  # the trio (<gem>-info/install/develop) is checked — a gem's other committed
  # agents, such as the_local's own creators, follow their own shape.
  class ProviderCheck
    FACETS = %w[info install develop].freeze

    def initialize(gem_root)
      @gem_root = gem_root
    end

    def problems
      trio_files.flat_map do |file|
        Format.problems(File.read(file)).map { |problem| "#{File.basename(file)}: #{problem}" }
      end
    end

    private

    def trio_files
      FACETS.map { |facet| File.join(@gem_root, "the_local", "agents", "#{gem_name}-#{facet}.md") }
            .select { |file| File.exist?(file) }
    end

    def gem_name
      File.basename(Dir.glob(File.join(@gem_root, "*.gemspec")).first.to_s, ".gemspec")
    end
  end
end
