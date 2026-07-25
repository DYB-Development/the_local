# frozen_string_literal: true

require_relative "interface"

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
      require_declared_interface
      FACETS.each { |facet| @runner.call(prompt_for(facet), @gem_root) }
    end

    def prompt_for(facet)
      File.read(File.join(CREATORS, "#{facet}.md"))
    end

    private

    def require_declared_interface
      return if File.exist?(File.join(@gem_root, Interface::FILE))

      raise Error, "the_local: declare this gem's public interface in " \
                   "#{Interface::FILE} before authoring its locals"
    end
  end
end
