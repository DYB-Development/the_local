# frozen_string_literal: true

require "test_helper"
require "the_local/builder"
require "tmpdir"

module TheLocal
  class BuilderTest < Minitest::Test
    # A guide carrying every canonical section, so validation passes on shape and
    # each test can vary just the part it exercises.
    COMPLETE_GUIDE = "### Interface\n`x`\n### Recipe\nr\n### Install\ns\n### Conventions\nc"

    def setup
      TheLocal.reset!
    end

    def register_develop(dir, knowledge)
      TheLocal.register("keystone_ui", prefix: "keystone", agents_dir: dir) do |c|
        c.agent "develop", description: "d", tools: "Read", body: "b", knowledge: knowledge
      end
    end

    def test_writes_each_agent_markdown_to_its_source_path
      Dir.mktmpdir do |dir|
        register_develop(dir, "API.")

        Builder.new(registry: TheLocal.registry).call
        path = File.join(dir, "keystone-develop.md")

        assert_equal TheLocal.registry.agents.first.to_markdown, File.read(path)
      end
    end

    def test_validate_rejects_an_agent_whose_knowledge_still_has_a_todo_marker
      Dir.mktmpdir do |dir|
        register_develop(dir, "TODO: the API")

        error = assert_raises(TheLocal::Error) do
          Builder.new(registry: TheLocal.registry, validate: true).call
        end

        assert_includes error.message, "keystone-develop"
      end
    end

    def test_validate_allows_a_guide_that_only_mentions_the_marker_inline
      Dir.mktmpdir do |dir|
        register_develop(dir, "#{COMPLETE_GUIDE}\nsee the `TODO:` note")

        assert_equal 1, Builder.new(registry: TheLocal.registry, validate: true).call.size
      end
    end

    def test_validate_rejects_a_guide_missing_a_required_section
      Dir.mktmpdir do |dir|
        register_develop(dir, "### Interface\n`foo`\n### Recipe\nr\n### Install\nsteps")

        error = assert_raises(TheLocal::Error) do
          Builder.new(registry: TheLocal.registry, validate: true).call
        end

        assert_includes error.message, "Conventions"
      end
    end

    def test_validate_requires_a_recipe_section
      Dir.mktmpdir do |dir|
        register_develop(dir, "### Interface\n`x`\n### Install\ns\n### Conventions\nc")

        error = assert_raises(TheLocal::Error) do
          Builder.new(registry: TheLocal.registry, validate: true).call
        end

        assert_includes error.message, "Recipe"
      end
    end
  end
end
