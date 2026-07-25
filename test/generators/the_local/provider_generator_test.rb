# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "rails/generators"
require "generators/the_local/provider_generator"

module TheLocal
  module Generators
    # Drives `the_local:provider`, which wires the_local into a gem — the
    # dependency and the Rakefile hook. The committed locals are authored by the
    # creator agents, not scaffolded here; the gem carries no Ruby and no guide.
    class ProviderGeneratorTest < Minitest::Test
      def run_generator_into(dir, name = "demo")
        File.write(File.join(dir, "#{name}.gemspec"), "")
        File.write(File.join(dir, "Gemfile"), "source \"https://rubygems.org\"\ngemspec\n")
        capture_io { ProviderGenerator.start([], destination_root: dir) }
      end

      def test_adds_the_local_as_a_dependency_to_the_gemfile
        Dir.mktmpdir do |dir|
          run_generator_into(dir)

          assert_includes File.read(File.join(dir, "Gemfile")), %(gem "the_local"\n)
        end
      end

      def test_points_the_next_step_at_declaring_the_interface
        Dir.mktmpdir do |dir|
          said, = run_generator_into(dir)

          assert_includes said, "the_local/interface.yml"
        end
      end

      def test_gemfile_injection_is_idempotent_on_rerun
        Dir.mktmpdir do |dir|
          run_generator_into(dir)
          capture_io { ProviderGenerator.start([], destination_root: dir) }

          assert_equal 1, File.read(File.join(dir, "Gemfile")).scan(ProviderGenerator::GEMFILE_LINE).size
        end
      end

      def test_does_not_add_a_self_reference_when_the_local_provisions_itself
        Dir.mktmpdir do |dir|
          File.write(File.join(dir, "the_local.gemspec"), "")
          File.write(File.join(dir, "Gemfile"), "source \"https://rubygems.org\"\ngemspec\n")
          capture_io { ProviderGenerator.start([], destination_root: dir) }

          refute_includes File.read(File.join(dir, "Gemfile")), ProviderGenerator::GEMFILE_LINE
        end
      end

      def test_hooks_the_rake_tasks_into_the_rakefile
        Dir.mktmpdir do |dir|
          File.write(File.join(dir, "Rakefile"), "# frozen_string_literal: true\n")
          run_generator_into(dir)

          assert_includes File.read(File.join(dir, "Rakefile")), %(require "the_local/rake")
        end
      end

      # An engine can only run the generator from test/dummy, so destination_root
      # is the dummy app; the generator must relocate to the gem root (the nearest
      # ancestor with a *.gemspec) before writing.
      def test_writes_to_the_gem_root_when_run_from_a_dummy_app
        Dir.mktmpdir do |gem_root|
          File.write(File.join(gem_root, "demo.gemspec"), "")
          File.write(File.join(gem_root, "Gemfile"), "source \"https://rubygems.org\"\ngemspec\n")
          dummy = File.join(gem_root, "test", "dummy")
          FileUtils.mkdir_p(dummy)
          capture_io { ProviderGenerator.start([], destination_root: dummy) }

          assert_includes File.read(File.join(gem_root, "Gemfile")), ProviderGenerator::GEMFILE_LINE
        end
      end
    end
  end
end
