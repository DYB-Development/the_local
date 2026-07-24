# frozen_string_literal: true

require "test_helper"
require "the_local/author"

module TheLocal
  class AuthorTest < Minitest::Test
    def test_runs_the_creators_in_facet_order
      seen = []
      runner = ->(prompt, _dir) { seen << prompt[/name: the_local-author-(\w+)/, 1] }

      Author.new(gem_root: "/gem", runner: runner).call

      assert_equal %w[info install develop], seen
    end

    def test_runs_each_creator_in_the_provider_gem
      dirs = []
      runner = ->(_prompt, dir) { dirs << dir }

      Author.new(gem_root: "/gem", runner: runner).call

      assert_equal ["/gem"] * 3, dirs
    end
  end
end
