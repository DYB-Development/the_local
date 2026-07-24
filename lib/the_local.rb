# frozen_string_literal: true

require_relative "the_local/version"
require_relative "the_local/agent"
require_relative "the_local/registry"
require_relative "the_local/installer"
require_relative "the_local/trigger_writer"
require_relative "the_local/scope"
require_relative "the_local/sync"
require_relative "the_local/refresh"
require_relative "the_local/disk_providers"

# Resident Claude Code expert subagents ("locals"), contributed by the gems and
# app a host depends on and installed into the host's .claude/agents/.
module TheLocal
  class Error < StandardError; end

  class << self
    def registry
      @registry ||= Registry.new
    end

    def reset!
      registry.clear
    end
  end
end

# In a Rails host, expose the the_local:refresh rake task. Skipped outside Rails
# so the gem core stays Rails-free.
require_relative "the_local/railtie" if defined?(Rails::Railtie)
