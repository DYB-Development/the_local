# frozen_string_literal: true

require "test_helper"
require "the_local/provider_check"
require "fileutils"
require "tmpdir"

module TheLocal
  class ProviderCheckTest < Minitest::Test
    def with_agent(markdown)
      Dir.mktmpdir do |root|
        agents = File.join(root, "the_local", "agents")
        FileUtils.mkdir_p(agents)
        File.write(File.join(agents, "demo-info.md"), markdown)
        yield root
      end
    end

    def test_names_the_file_and_its_problem
      with_agent("---\nname: demo-info\n---\n") do |root|
        assert_includes ProviderCheck.new(root).problems, "demo-info.md: missing key: scope"
      end
    end
  end
end
