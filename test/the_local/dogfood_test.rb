# frozen_string_literal: true

require "test_helper"
require "the_local/provider_check"

module TheLocal
  class DogfoodTest < Minitest::Test
    def gem_root
      File.expand_path("../..", __dir__)
    end

    def test_committed_locals_match_the_declared_interface
      assert_empty ProviderCheck.new(gem_root).problems
    end
  end
end
