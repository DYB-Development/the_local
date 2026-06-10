# frozen_string_literal: true

require "test_helper"
require "the_local/process_doc_writer"
require "tmpdir"

module TheLocal
  class ProcessDocWriterTest < Minitest::Test
    def writer(dir)
      ProcessDocWriter.new(destination: dir)
    end

    def test_block_includes_the_one_time_exception_rule
      Dir.mktmpdir do |dir|
        assert_includes writer(dir).block, "one-time exception"
      end
    end
  end
end
