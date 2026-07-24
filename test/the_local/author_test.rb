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
  end
end
