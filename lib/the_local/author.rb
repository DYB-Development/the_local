# frozen_string_literal: true

module TheLocal
  class Author
    FACETS = %w[info install develop].freeze
    CREATORS = File.expand_path("creators", __dir__)

    ClaudeRunner = lambda do |prompt, dir|
      system("claude", "-p", prompt, "--allowedTools", "Read,Grep,Write",
             "--permission-mode", "acceptEdits", chdir: dir) ||
        raise(Error, "the_local: the creator run failed in #{dir} (is the `claude` CLI installed?)")
    end

    def initialize(gem_root:, runner: ClaudeRunner)
      @gem_root = gem_root
      @runner = runner
    end

    def call
      FACETS.each { |facet| @runner.call(prompt_for(facet), @gem_root) }
    end

    def prompt_for(facet)
      File.read(File.join(CREATORS, "#{facet}.md"))
    end
  end
end
