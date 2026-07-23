# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "rails/generators"
require "the_local/builder"
require "generators/the_local/provider_generator"

module TheLocal
  module Generators
    # Drives `the_local:provider`, the generator that scaffolds a gem's guide —
    # the only file a provider writes. The gem name comes from the gemspec, and
    # the_local renders the locals from the guide; the gem carries no Ruby.
    class ProviderGeneratorTest < Minitest::Test
      def run_generator_into(dir, name = "demo")
        File.write(File.join(dir, "#{name}.gemspec"), "")
        File.write(File.join(dir, "Gemfile"), "source \"https://rubygems.org\"\ngemspec\n")
        capture_io { ProviderGenerator.start([], destination_root: dir) }
      end

      def test_scaffolds_the_guide_at_the_gem_root
        Dir.mktmpdir do |dir|
          run_generator_into(dir)

          assert_path_exists File.join(dir, "the_local/guide.md")
        end
      end

      def test_names_the_guide_for_the_gem_from_its_gemspec
        Dir.mktmpdir do |dir|
          run_generator_into(dir, "citizen")

          assert_includes File.read(File.join(dir, "the_local/guide.md")), "citizen"
        end
      end

      def test_guide_demands_the_interface_and_states_the_no_source_bar
        Dir.mktmpdir do |dir|
          run_generator_into(dir)
          guide = File.read(File.join(dir, "the_local/guide.md"))

          assert_includes guide, "### Interface"
          assert_includes guide, "exact signature"
          assert_includes guide, "without ever opening"
        end
      end

      def test_guide_carries_every_canonical_section_the_gate_requires
        Dir.mktmpdir do |dir|
          run_generator_into(dir)
          guide = File.read(File.join(dir, "the_local/guide.md"))

          TheLocal::Builder::REQUIRED_SECTIONS.each { |section| assert_includes guide, section }
        end
      end

      def test_adds_the_local_as_a_build_tool_to_the_gemfile
        Dir.mktmpdir do |dir|
          run_generator_into(dir)

          assert_includes File.read(File.join(dir, "Gemfile")), %(gem "the_local"\n)
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

      def test_hooks_the_build_task_into_the_rakefile
        Dir.mktmpdir do |dir|
          File.write(File.join(dir, "Rakefile"), "# frozen_string_literal: true\n")
          run_generator_into(dir)

          assert_includes File.read(File.join(dir, "Rakefile")), %(require "the_local/rake")
        end
      end

      def test_scaffolds_for_a_hyphenated_gem
        Dir.mktmpdir do |dir|
          run_generator_into(dir, "event_engine-subscribers")

          assert_includes File.read(File.join(dir, "the_local/guide.md")), "event_engine-subscribers"
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

          assert_path_exists File.join(gem_root, "the_local/guide.md")
        end
      end
    end
  end
end
