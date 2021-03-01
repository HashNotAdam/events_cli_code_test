# frozen_string_literal: true

require "interactors/application_interactor"
require "interactors/log/info"
require "presenters/talk_presenter"
require "repositories/talks"

class PrintTalks < ApplicationInteractor
  param :event_name

  def call
    talks = Talks.where(:event_name, event_name)
    error(%(There are no talks registered for "#{event_name}")) if talks.empty?

    Log::Info.(message: talks_message(talks))
  end

  private

  def talks_message(talks)
    messages = order_by_start_time(talks).map do
      TalkPresenter.new(_1).to_s
    end
    messages.join
  end

  def order_by_start_time(talks)
    talks.sort_by(&:start_time)
  end
end
