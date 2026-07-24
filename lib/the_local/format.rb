# frozen_string_literal: true

module TheLocal
  # The fixed shape every committed local shares, regardless of which gem it
  # documents or which creator agent authored it. The renderer is gone; this is
  # the contract that keeps the trio consistent — checked for structure, never
  # for content.
  module Format
    FRONT_MATTER_KEYS = %w[name description tools scope].freeze
  end
end
