# frozen_string_literal: true

require "test_helper"
require "the_local/reference"

module TheLocal
  class ReferenceTest < Minitest::Test
    def test_content_reads_the_committed_guide
      assert_includes Reference.content, "## TheLocal"
    end

    def test_install_section_leads_with_the_cli
      assert_includes Reference.content, "bundle exec the_local install"
    end

    # the_local's own guide is the exemplar every provider copies, so it must
    # surface the literal interface — exact signatures — not just prose about it.
    def test_surfaces_the_literal_register_and_agent_signatures
      content = Reference.content

      assert_includes content, "### Interface"
      assert_includes content, "TheLocal.register(gem_name, prefix: gem_name, scope: nil, agents_dir: nil)"
      assert_includes content, "c.agent(name, description:, tools:, body:, knowledge: nil)"
    end

    # The exemplar must model every canonical section the gate enforces, since
    # the develop local copies its shape into the guides it authors.
    def test_models_all_canonical_sections
      content = Reference.content

      ["### Interface", "### Recipe", "### Install", "### Conventions"].each do |section|
        assert_includes content, section
      end
    end
  end
end
