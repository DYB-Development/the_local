# frozen_string_literal: true

require_relative "format"
require_relative "front_matter"
require_relative "interface"

module TheLocal
  class ProviderCheck
    LOCALS = %w[info install develop].freeze

    def initialize(gem_root)
      @gem_root = gem_root
    end

    def problems
      format_problems + scope_problems + interface_problems
    end

    private

    def format_problems
      existing_files.flat_map do |file|
        Format.problems(File.read(file)).map { |problem| "#{File.basename(file)}: #{problem}" }
      end
    end

    def scope_problems
      return disagreement_problems if declared.scope.nil?

      existing_files.reject { |file| FrontMatter.new(File.read(file)).scope == declared.scope }
                    .map { |file| "#{File.basename(file)}: scope does not match the manifest" }
    end

    def disagreement_problems
      scopes = existing_files.map { |file| FrontMatter.new(File.read(file)).scope }.compact.uniq
      scopes.size > 1 ? ["the locals' scope lines disagree"] : []
    end

    def interface_problems
      return [] if LOCALS.all? { |local| declared.entry_points_for(local).empty? }

      LOCALS.select { |local| File.exist?(file_for(local)) }
            .flat_map { |local| undocumented(local) + misdocumented(local) }
    end

    def undocumented(local)
      declared.entry_points_for(local)
              .reject { |entry_point| documented(local).any? { |span| span.include?(entry_point) } }
              .map { |entry_point| "#{name_of(local)}: undocumented entry point: #{entry_point}" }
    end

    def misdocumented(local)
      documented(local).reject { |span| declared_in(span) == local }
                       .map { |span| "#{name_of(local)}: #{misplacement(span)}" }
    end

    def misplacement(span)
      owner = declared_in(span)
      owner ? "entry point declared for #{owner}: #{span}" : "undeclared entry point: #{span}"
    end

    def declared_in(span)
      LOCALS.find do |local|
        declared.entry_points_for(local).any? { |entry_point| span.include?(entry_point) }
      end
    end

    def documented(local)
      Format.section(File.read(file_for(local)), "## Interface").scan(/^\s*-\s+`([^`\n]+)`/).flatten
    end

    def declared
      @declared ||= Interface.at(@gem_root)
    end

    def existing_files
      LOCALS.map { |local| file_for(local) }.select { |file| File.exist?(file) }
    end

    def file_for(local)
      File.join(@gem_root, "the_local", "agents", name_of(local))
    end

    def name_of(local)
      "#{gem_name}-#{local}.md"
    end

    def gem_name
      File.basename(Dir.glob(File.join(@gem_root, "*.gemspec")).first.to_s, ".gemspec")
    end
  end
end
