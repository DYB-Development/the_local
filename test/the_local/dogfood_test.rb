# frozen_string_literal: true

require "test_helper"
require "the_local/provider_build"

module TheLocal
  # the_local is its own first provider: its committed the_local/agents/*.md must
  # equal what ProviderBuild renders from the_local/guide.md, or the gem ships
  # locals that lie about its own interface.
  class DogfoodTest < Minitest::Test
    def gem_root
      File.expand_path("../..", __dir__)
    end

    def test_committed_agents_match_the_rendered_build
      ProviderBuild.new(gem_root).agents.each do |agent|
        assert_equal agent.to_markdown, File.read(agent.source_path)
      end
    end
  end
end
