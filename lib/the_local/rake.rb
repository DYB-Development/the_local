# frozen_string_literal: true

require "rake"
require "the_local"
require "the_local/author"
require "the_local/provider_check"

namespace :the_local do
  desc "Author this provider's committed locals from its current source"
  task :author do
    TheLocal::Author.new(gem_root: Dir.pwd).call
    puts "the_local: authored locals; review the_local/agents/ and run `rake the_local:check`"
  end

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
