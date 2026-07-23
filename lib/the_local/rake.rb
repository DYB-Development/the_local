# frozen_string_literal: true

require "rake"
require "the_local"
require "the_local/provider_build"

# Gem-side build task. A provider adds `require "the_local/rake"` to its Rakefile
# and runs `rake the_local:build` to (re)render its committed agent files from
# its the_local/guide.md — no registration code in the gem. Host apps don't use
# this; they install/refresh.
namespace :the_local do
  desc "Render this provider's committed agent files from its the_local/guide.md"
  task :build do
    written = TheLocal::ProviderBuild.new(Dir.pwd).call
    puts "the_local: built #{written.length} agent file(s)"
  end

  desc "Install/refresh this project's locals from the current bundle into .claude/agents/"
  task :install do
    allowed = TheLocal::Refresh.call(destination: Dir.pwd)
    puts "the_local: installed locals for #{allowed.join(", ")}"
  end
end
