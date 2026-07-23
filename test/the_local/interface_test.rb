# frozen_string_literal: true

require "test_helper"

module TheLocal
  class InterfaceTest < Minitest::Test
    def test_offers_the_standard_trio
      agents = Interface.agents(gem_name: "demo", knowledge: "the guide", agents_dir: "/agents")

      assert_equal %w[info install develop], agents.map(&:name)
    end
  end
end
