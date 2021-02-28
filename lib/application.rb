# frozen_string_literal: true

require "interactors/application_interactor"
require "interactors/log/info"

class Application < ApplicationInteractor
  def call
    Log::Info.(message: "ABC", something_else: "DEF")
  end
end
