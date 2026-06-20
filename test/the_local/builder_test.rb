# frozen_string_literal: true

require "test_helper"
require "the_local/builder"
require "tmpdir"

module TheLocal
  class BuilderTest < Minitest::Test
    def setup
      TheLocal.reset!
    end

    def test_writes_each_agent_markdown_to_its_source_path
      Dir.mktmpdir do |dir|
        TheLocal.register("keystone_ui", prefix: "keystone", agents_dir: dir) do |c|
          c.agent "develop", description: "Build UI.", tools: "Read", body: "You build.", knowledge: "API."
        end

        Builder.new(registry: TheLocal.registry).call
        path = File.join(dir, "keystone-develop.md")

        assert_equal TheLocal.registry.agents.first.to_markdown, File.read(path)
      end
    end

    def test_validate_rejects_an_agent_whose_knowledge_still_has_a_todo_marker
      Dir.mktmpdir do |dir|
        TheLocal.register("keystone_ui", prefix: "keystone", agents_dir: dir) do |c|
          c.agent "develop", description: "Build UI.", tools: "Read", body: "b", knowledge: "TODO: the API"
        end

        error = assert_raises(TheLocal::Error) do
          Builder.new(registry: TheLocal.registry, validate: true).call
        end

        assert_includes error.message, "keystone-develop"
      end
    end

    def test_validate_allows_a_guide_that_only_mentions_the_marker_inline
      Dir.mktmpdir do |dir|
        TheLocal.register("keystone_ui", prefix: "keystone", agents_dir: dir) do |c|
          c.agent "develop", description: "d", tools: "Read", body: "b", knowledge: "a `TODO:` mention"
        end

        assert_equal 1, Builder.new(registry: TheLocal.registry, validate: true).call.size
      end
    end
  end
end
