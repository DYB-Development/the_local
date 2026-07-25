# frozen_string_literal: true

require "test_helper"
require "the_local/interface"
require "fileutils"
require "tmpdir"

module TheLocal
  class InterfaceTest < Minitest::Test
    def with_manifest(yaml)
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p(File.join(root, "the_local"))
        File.write(File.join(root, "the_local", "interface.yml"), yaml)
        yield root
      end
    end

    def test_reads_the_declared_scope
      with_manifest("scope: emitting events\n") do |root|
        assert_equal "emitting events", Interface.at(root).scope
      end
    end

    def test_reads_the_declared_entry_points
      with_manifest("interface:\n  - Demo.emit\n  - rake demo:drain\n") do |root|
        assert_equal ["Demo.emit", "rake demo:drain"], Interface.at(root).entry_points
      end
    end
  end
end
