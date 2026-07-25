# frozen_string_literal: true

require_relative "format"
require_relative "front_matter"
require_relative "interface"

module TheLocal
  class ProviderCheck
    FACETS = %w[info install develop].freeze

    def initialize(gem_root)
      @gem_root = gem_root
    end

    def problems
      per_file_problems + scope_agreement_problems + coverage_problems +
        over_reach_problems + scope_declaration_problems
    end

    private

    def coverage_problems
      trio_files.flat_map do |file|
        documented = Format.section(File.read(file), "## Interface")
        declared.entry_points.reject { |entry_point| documented.include?(entry_point) }
                             .map { |entry_point| "#{File.basename(file)}: undocumented entry point: #{entry_point}" }
      end
    end

    def over_reach_problems
      return [] if declared.entry_points.empty?

      trio_files.flat_map do |file|
        documented_spans(File.read(file))
          .reject { |span| declared.entry_points.any? { |entry_point| span.include?(entry_point) } }
          .map { |span| "#{File.basename(file)}: undeclared entry point: #{span}" }
      end
    end

    def documented_spans(markdown)
      Format.section(markdown, "## Interface").scan(/`([^`\n]+)`/).flatten
    end

    def scope_declaration_problems
      return [] if declared.scope.nil?

      trio_files.reject { |file| FrontMatter.new(File.read(file)).scope == declared.scope }
                .map { |file| "#{File.basename(file)}: scope does not match the manifest" }
    end

    def declared
      @declared ||= Interface.at(@gem_root)
    end

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
