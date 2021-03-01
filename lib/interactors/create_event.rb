# frozen_string_literal: true

require "interactors/application_interactor"
require "interactors/log/info"
require "models/event"
require "repositories/events"

class CreateEvent < ApplicationInteractor
  param :name

  def call
    record = Event.new(name: name)
    Events << record

    Log::Info.(message: %(Event "#{name}" has been created))
  end
end
