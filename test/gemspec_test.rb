# frozen_string_literal: true

require "test_helper"

class GemspecTest < Minitest::Test
  def spec
    @spec ||= Gem::Specification.load(File.expand_path("../the_local.gemspec", __dir__))
  end

  def test_source_code_uri_is_distinct_from_the_homepage
    refute_equal spec.metadata["homepage_uri"], spec.metadata["source_code_uri"]
  end
end
