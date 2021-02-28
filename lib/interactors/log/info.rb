# frozen_string_literal: true

module Log
  class Info
    attr_reader :message

    def self.call(message:)
      new(message: message).call
    end

    def initialize(message:)
      @message = message
    end

    def call
      $stdout.puts(message)
    end
  end
end
