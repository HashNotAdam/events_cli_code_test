# frozen_string_literal: true

require "interactors/application_interactor"
require "interactors/log/info"
require "models/speaker"
require "repositories/speakers"

class CreateSpeaker < ApplicationInteractor
  param :name

  def call
    record = Speaker.new(name: name)
    Speakers << record

    Log::Info.(message: %(Speaker "#{name}" has been created))
  end
end
