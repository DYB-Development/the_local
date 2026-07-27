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

    def test_reads_the_entry_points_declared_for_one_facet
      with_manifest("install:\n  - rake demo:setup\ndevelop:\n  - Demo.emit\n") do |root|
        assert_equal ["Demo.emit"], Interface.at(root).entry_points_for("develop")
      end
    end
  end
end
