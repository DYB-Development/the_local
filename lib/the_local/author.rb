# frozen_string_literal: true

module TheLocal
  # Runs the_local's creator agents against a provider gem to author its trio.
  # The creators are the_local's own function — prompt assets it owns, never
  # installed into a host — so authoring is `rake the_local:author`, not loose
  # agent files. The facets run in sequence so their scope lines can't diverge.
  class Author
    FACETS = %w[info install develop].freeze
    CREATORS = File.expand_path("creators", __dir__)

    def initialize(gem_root:, runner:)
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
