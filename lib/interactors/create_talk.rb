# frozen_string_literal: true

require "interactors/application_interactor"
require "interactors/log/info"
require "models/talk"
require "repositories/talks"

class CreateTalk < ApplicationInteractor
  param :event_name
  param :name
  param :start_time
  param :end_time
  param :speaker_name

  def call
    record = Talk.new(
      event_name: event_name,
      name: name,
      start_time: start_time,
      end_time: end_time,
      speaker_name: speaker_name
    )
    Talks << record

    Log::Info.(message: %(Talk "#{name}" has been created))
  rescue InvalidRecordError => e
    error(e.message)
  end
end
