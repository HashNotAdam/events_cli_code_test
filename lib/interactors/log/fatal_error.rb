# frozen_string_literal: true

require "interactors/log/error"

module Log
  class FatalError < Error
    def call
      super
      exit(1)
    end
  end
end
