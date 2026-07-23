# frozen_string_literal: true

require "test_helper"
require "rake"
require "fileutils"
require "tmpdir"

module TheLocal
  class RakeTest < Minitest::Test
    def test_build_task_rejects_a_guide_with_todo_placeholders
      Dir.mktmpdir do |root|
        File.write(File.join(root, "demo.gemspec"), "")
        FileUtils.mkdir_p(File.join(root, "the_local"))
        File.write(File.join(root, "the_local", "guide.md"), "TODO: the API")

        Dir.chdir(root) do
          assert_raises(TheLocal::Error) { rake_app["the_local:build"].invoke }
        end
      end
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
