# frozen_string_literal: true

require "rake"
require "the_local"
require "the_local/provider_check"

# Gem-side tasks. A provider adds `require "the_local/rake"` to its Rakefile.
# `the_local:check` verifies its committed locals hold the format; the creator
# agents author them. Host apps don't use these; they install/refresh.
namespace :the_local do
  desc "Check this provider's committed locals hold the fixed format"
  task :check do
    problems = TheLocal::ProviderCheck.new(Dir.pwd).problems
    raise TheLocal::Error, "the_local: malformed local(s):\n- #{problems.join("\n- ")}" if problems.any?

    puts "the_local: locals hold the format"
  end

  desc "Install/refresh this project's locals from the current bundle into .claude/agents/"
  task :install do
    allowed = TheLocal::Refresh.call(destination: Dir.pwd)
    puts "the_local: installed locals for #{allowed.join(", ")}"
  end
end
