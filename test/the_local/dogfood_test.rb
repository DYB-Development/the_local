# frozen_string_literal: true

require "test_helper"
require "the_local/provider_check"

module TheLocal
  # the_local is its own first provider: its committed the_local/agents/*.md must
  # hold the fixed format, or the gem ships a trio that lies about its own shape.
  class DogfoodTest < Minitest::Test
    def gem_root
      File.expand_path("../..", __dir__)
    end

    def test_committed_trio_holds_the_format
      assert_empty ProviderCheck.new(gem_root).problems
    end
  end
end
