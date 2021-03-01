# frozen_string_literal: true

require "interactors/application_interactor"
require "interactors/documentation"
require "interactors/input_parser"
require "interactors/log/info"

class Application < ApplicationInteractor
  def call
    log_documentation

    loop do
      command = InputParser.(input: user_input)
      break if command&.dig(:interactor) == Exit

      if command.nil?
        log_documentation
      else
        command[:interactor].(**command[:arguments])
      end
    end
  end

  def user_input
    gets.chomp
  end

  private

  def log_documentation
    Log::Info.(message: Documentation.call)
  end
end
