# frozen_string_literal: true

require "test_helper"
require "rake"
require "tmpdir"

module TheLocal
  class RakeTest < Minitest::Test
    def test_build_task_rejects_a_guide_with_todo_placeholders
      TheLocal.reset!
      Dir.mktmpdir do |dir|
        TheLocal.register("keystone_ui", prefix: "keystone", agents_dir: dir) do |c|
          c.agent "develop", description: "d", tools: "Read", body: "b", knowledge: "TODO: the API"
        end

        assert_raises(TheLocal::Error) { rake_app["the_local:build"].invoke }
      end
    ensure
      TheLocal.reset!
    end

    def test_defines_the_build_rake_task
      assert rake_app.lookup("the_local:build")
    end

    def test_defines_the_install_rake_task
      assert rake_app.lookup("the_local:install")
    end

    private

    def rake_app
      app = Rake::Application.new
      Rake.application = app
      load File.expand_path("../../lib/the_local/rake.rb", __dir__)
      app
    end
  end
end
