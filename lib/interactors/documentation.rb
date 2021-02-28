# frozen_string_literal: true

require "interactors/application_interactor"
require "interactors/log/info"

class Documentation < ApplicationInteractor
  DOCUMENTATION = <<~MESSAGE.strip
    Commands
    --------

    CREATE EVENT event_name
      Example: CREATE EVENT an_event
      Restrictions:
        - Cannot include spaces
    CREATE SPEAKER speaker_name
    CREATE TALK event_name 'talk_name' start_time end_time speaker_name
      Example: CREATE TALK an_event 'My Talk' 9:00am 10:00am John
      Restrictions:
        - A talk must have 1 speaker
        - A talk must have a start and end time
        - Talk times cannot overlap and they must be in sequential order
    PRINT TALKS event_name
    EXIT

    Enter command:
  MESSAGE
  private_constant :DOCUMENTATION

  def call
    DOCUMENTATION
  end
end
