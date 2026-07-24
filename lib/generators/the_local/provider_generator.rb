# frozen_string_literal: true

require "rails/generators"

module TheLocal
  module Generators
    # `bin/rails g the_local:provider` — wires the provider side of the_local into
    # a gem: adds the dependency and the Rakefile hook that exposes
    # `rake the_local:check`. The gem writes no guide and no Ruby of its own; the
    # committed locals are authored by the the_local-author-* creator agents.
    #
    # The companion app side is `the_local:install`; this is its mirror for the
    # gems that *contribute* locals. See PROVIDERS.md.
    class ProviderGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      GEMFILE_LINE = %(gem "the_local")
      RAKEFILE_REQUIRE = %(require "the_local/rake")

      desc "Wire the_local provider tooling into this gem"

      def relocate_to_gem_root
        self.destination_root = gem_root
      end

      def announce_next_step
        say "Run the the_local-author-info/install/develop agents to author " \
            "this gem's locals into the_local/agents/, then commit them."
      end

      def add_to_gemfile
        return if gem_name == "the_local"

        gemfile = File.join(destination_root, "Gemfile")
        return unless File.exist?(gemfile)
        return if File.read(gemfile).include?(GEMFILE_LINE)

        append_to_file "Gemfile",
                       "\n# the_local renders #{gem_name}'s committed locals at build time.\n#{GEMFILE_LINE}\n"
      end

      def hook_build_task_into_rakefile
        return unless File.exist?(File.join(destination_root, "Rakefile"))
        return if File.read(File.join(destination_root, "Rakefile")).include?(RAKEFILE_REQUIRE)

        append_to_file "Rakefile",
                       "\n# Render #{gem_name}'s committed the_local agent files: `rake the_local:build`.\n" \
                       "#{RAKEFILE_REQUIRE}\n"
      end

      private

      def gem_name
        File.basename(gemspec.to_s, ".gemspec")
      end

      def module_name
        gem_name.split("-").map { |segment| segment.split("_").map(&:capitalize).join }.join("::")
      end

      def gem_root
        gemspec ? File.dirname(gemspec) : destination_root
      end

      def gemspec
        ascend_to_gemspec(destination_root)
      end

      def ascend_to_gemspec(start)
        dir = File.expand_path(start)
        loop do
          found = Dir.glob(File.join(dir, "*.gemspec")).first
          return found if found

          parent = File.dirname(dir)
          return nil if parent == dir

          dir = parent
        end
      end
    end
  end
end
