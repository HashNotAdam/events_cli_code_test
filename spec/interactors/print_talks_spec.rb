# frozen_string_literal: true

require "interactors/log/error"
require "interactors/log/info"
require "interactors/print_talks"
require "models/event"
require "models/speaker"
require "models/talk"
require "repositories/events"
require "repositories/speakers"
require "repositories/talks"

RSpec.describe PrintTalks do
  before do
    allow(Log::Info).to receive(:call)
    allow(Log::Error).to receive(:call)

    Events << Event.new(name: "My event")
    Speakers << Speaker.new(name: "John")
    Talks << Talk.new(
      event_name: "My event",
      name: "My First Talk",
      start_time: "9:00am",
      end_time: "10:00am",
      speaker_name: "John"
    )
    Speakers << Speaker.new(name: "Bob")
    Talks << Talk.new(
      event_name: "My event",
      name: "code challenges",
      start_time: "2:00pm",
      end_time: "2:30pm",
      speaker_name: "Bob"
    )
    Speakers << Speaker.new(name: "Ben")
    Talks << Talk.new(
      event_name: "My event",
      name: "Joint Talk",
      start_time: "10:30am",
      end_time: "12:00pm",
      speaker_name: "Ben"
    )
  end

  after do
    Events.clear_all
    Speakers.clear_all
    Talks.clear_all
  end

  it "logs all the talks for the event in order of start time" do
    described_class.(event_name: "My event")
    expect(Log::Info).to have_received(:call).with(
      message: <<~MESSAGE
        9:00am – 10:00am
          My First Talk presented by John
        10:30am – 12:00pm
          Joint Talk presented by Ben
        2:00pm – 2:30pm
          code challenges presented by Bob
      MESSAGE
    )
  end

  context "when there are no talks registered for the event" do
    it "logs an error" do
      described_class.(event_name: "Unknown event")
      expect(Log::Error).to have_received(:call).with(
        message: %(There are no talks registered for "Unknown event")
      )
    end

    it "stops execution" do
      described_class.(event_name: "Unknown event")
      expect(Log::Info).not_to have_received(:call)
    end
  end
end
