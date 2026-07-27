# frozen_string_literal: true

require "rails/generators"

module TheLocal
  module Generators
    class ProviderGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      GEMFILE_LINE = %(gem "the_local")
      RAKEFILE_REQUIRE = %(require "the_local/rake")

      desc "Wire the_local provider tooling into this gem"

      def relocate_to_gem_root
        self.destination_root = gem_root
      end

      def announce_next_step
        say "Declare this gem's public interface in the_local/interface.yml, then " \
            "run `rake the_local:author` to write its locals into the_local/agents/."
      end

      def add_to_gemfile
        return if gem_name == "the_local"

        gemfile = File.join(destination_root, "Gemfile")
        return unless File.exist?(gemfile)
        return if File.read(gemfile).include?(GEMFILE_LINE)

        append_to_file "Gemfile", "\n#{GEMFILE_LINE}\n"
      end

      def hook_check_task_into_rakefile
        return unless File.exist?(File.join(destination_root, "Rakefile"))
        return if File.read(File.join(destination_root, "Rakefile")).include?(RAKEFILE_REQUIRE)

        append_to_file "Rakefile", "\n#{RAKEFILE_REQUIRE}\n"
      end

      private

      def gem_name
        File.basename(gemspec.to_s, ".gemspec")
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
