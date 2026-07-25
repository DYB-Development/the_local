# frozen_string_literal: true

require_relative "format"
require_relative "front_matter"

module TheLocal
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
