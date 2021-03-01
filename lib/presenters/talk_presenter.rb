# frozen_string_literal: true

require "presenters/application_presenter"

class TalkPresenter < ApplicationPresenter
  def to_s
    <<~MESSAGE
      #{schedule}
        #{object.name} presented by #{object.speaker_name}
    MESSAGE
  end

  def schedule
    start_time = object.start_time.strftime("%l:%M%P").strip
    end_time = object.end_time.strftime("%l:%M%P").strip
    "#{start_time} – #{end_time}"
  end
end
