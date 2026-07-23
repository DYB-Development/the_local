# frozen_string_literal: true

require "test_helper"
require "the_local/provider_build"
require "fileutils"
require "tmpdir"

module TheLocal
  class ProviderBuildTest < Minitest::Test
    COMPLETE_GUIDE = "### Interface\n`x`\n### Recipe\nr\n### Install\ns\n### Conventions\nc"

    def with_gem_root(name)
      Dir.mktmpdir do |root|
        File.write(File.join(root, "#{name}.gemspec"), "")
        FileUtils.mkdir_p(File.join(root, "the_local"))
        File.write(File.join(root, "the_local", "guide.md"), COMPLETE_GUIDE)
        yield root
      end
    end

    def test_renders_the_interface_for_the_gem_named_by_its_gemspec
      with_gem_root("demo") do |root|
        agents = ProviderBuild.new(root).agents

        assert_equal %w[demo-info demo-install demo-develop], agents.map(&:qualified_name)
      end
    end
  end
end
