# frozen_string_literal: true

require "rails/generators"

module TheLocal
  module Generators
    # `bin/rails g the_local:provider` — scaffolds the provider side of the_local
    # into a gem: a single the_local/guide.md, plus the Rakefile hook that exposes
    # `rake the_local:build`. The gem name comes from the gemspec, and the_local
    # renders the locals from the guide, so the gem carries no Ruby of its own.
    #
    # The companion app side is `the_local:install`; this is its mirror for the
    # gems that *contribute* locals. See PROVIDERS.md.
    class ProviderGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      GEMFILE_LINE = %(gem "the_local")
      RAKEFILE_REQUIRE = %(require "the_local/rake")

      desc "Scaffold the_local provider wiring (a guide) into this gem"

      def relocate_to_gem_root
        self.destination_root = gem_root
      end

      def create_guide
        template "guide.md.tt", "the_local/guide.md"
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
