# frozen_string_literal: true

require "test_helper"
require "the_local/author"
require "fileutils"
require "tmpdir"

module TheLocal
  class AuthorTest < Minitest::Test
    def with_declared_interface
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p(File.join(root, "the_local"))
        File.write(File.join(root, Interface::FILE), "develop:\n  - Demo.emit\n")
        yield root
      end
    end

    def test_refuses_to_author_without_a_declared_interface
      Dir.mktmpdir do |root|
        author = Author.new(gem_root: root, runner: ->(_prompt, _dir) {})

        assert_match(%r{the_local/interface\.yml}, assert_raises(Error) { author.call }.message)
      end
    end

    def test_runs_the_creators_in_facet_order
      seen = []
      runner = ->(prompt, _dir) { seen << prompt[/name: the_local-author-(\w+)/, 1] }

      with_declared_interface { |root| Author.new(gem_root: root, runner: runner).call }

      assert_equal %w[info install develop], seen
    end

    def test_hands_the_prompt_to_claude_after_the_option_terminator
      assert_equal ["--", "a prompt"], Author.claude_command("a prompt").last(2)
    end

    def test_runs_each_creator_in_the_provider_gem
      dirs = []
      runner = ->(_prompt, dir) { dirs << dir }

      with_declared_interface do |root|
        Author.new(gem_root: root, runner: runner).call

        assert_equal [root] * 3, dirs
      end
    end
  end
end
