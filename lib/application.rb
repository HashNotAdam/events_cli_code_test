# frozen_string_literal: true

require "interactors/application_interactor"
require "interactors/documentation"
require "interactors/input_parser"
require "interactors/log/info"

class Application < ApplicationInteractor
  def call
    log_documentation
    log_command_prompt

    loop do
      command = InputParser.(input: user_input)
      break if command&.dig(:interactor) == Exit

      process_user_input(command)
    end
  end

  def process_user_input(command)
    if command.nil?
      log_documentation
    else
      command[:interactor].(**command[:arguments])
    end

    log_command_prompt
  end

  def user_input
    gets.chomp
  end

  private

  def log_documentation
    Log::Info.(message: Documentation.call)
  end

  def log_command_prompt
    Log::Info.(message: "\nEnter command:")
  end
end
