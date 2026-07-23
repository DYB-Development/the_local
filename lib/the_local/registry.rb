# frozen_string_literal: true

module TheLocal
  # A registered provider (gem or app): its gem name, filename prefix, and a
  # one-line scope used to generate the delegation trigger.
  Provider = Data.define(:gem_name, :prefix, :scope)

  # Accumulates the providers and agents discovered from disk. Installer and
  # TriggerWriter read this to write .claude/agents/ and the delegation trigger.
  class Registry
    def initialize
      @agents = []
      @providers = []
    end

    attr_reader :agents, :providers

    def add(agent)
      @agents << agent
    end

    def add_provider(provider)
      @providers << provider
    end

    def clear
      @agents.clear
      @providers.clear
    end
  end
end
