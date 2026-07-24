# frozen_string_literal: true

require_relative "format"
require_relative "front_matter"

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
      per_file_problems + scope_agreement_problems
    end

    private

    def per_file_problems
      trio_files.flat_map do |file|
        Format.problems(File.read(file)).map { |problem| "#{File.basename(file)}: #{problem}" }
      end
    end

    # scope is one provider-level phrase held redundantly in every trio file, so
    # the three must agree. They can diverge when the creators run concurrently
    # and each authors its own; a structure-only check would miss it.
    def scope_agreement_problems
      scopes = trio_files.map { |file| FrontMatter.new(File.read(file)).scope }.compact.uniq
      scopes.size > 1 ? ["the trio's scope lines diverge"] : []
    end

    def trio_files
      FACETS.map { |facet| File.join(@gem_root, "the_local", "agents", "#{gem_name}-#{facet}.md") }
            .select { |file| File.exist?(file) }
    end

    def gem_name
      File.basename(Dir.glob(File.join(@gem_root, "*.gemspec")).first.to_s, ".gemspec")
    end
  end
end
