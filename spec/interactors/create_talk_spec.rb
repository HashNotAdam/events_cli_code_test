# frozen_string_literal: true

require "interactors/create_talk"
require "interactors/log/info"
require "interactors/log/error"
require "models/event"
require "models/speaker"
require "repositories/events"
require "repositories/speakers"
require "repositories/talks"

RSpec.describe CreateTalk do
  let(:event) { Events << Event.new(name: "My event") }
  let(:speaker) { Speakers << Speaker.new(name: "Abc Def") }

  before do
    allow(Log::Info).to receive(:call)
    allow(Log::Error).to receive(:call)
  end

  after do
    Events.clear_all
    Speakers.clear_all
    Talks.clear_all
  end

  it "adds a new talk to the Talks repository" do
    expect do
      described_class.(
        event_name: event.name,
        name: "My talk",
        start_time: "9:00am",
        end_time: "10:00am",
        speaker_name: speaker.name
      )
    end.to change { Talks.all.count }.by(1)
  end

  it "logs an acknowledgement" do
    described_class.(
      event_name: event.name,
      name: "My talk",
      start_time: "9:00am",
      end_time: "10:00am",
      speaker_name: speaker.name
    )
    expect(Log::Info).to have_received(:call).
      with(message: %(Talk "My talk" has been created))
  end

  context "when the event does not exist" do
    let(:call) do
      described_class.(
        event_name: "Unknown event",
        name: "My talk",
        start_time: "9:00am",
        end_time: "10:00am",
        speaker_name: speaker.name
      )
    end

    it "logs an error" do
      call
      expect(Log::Error).to have_received(:call).with(
        message: <<~MESSAGE.chomp
          Error: Talk is not valid.
          \s\s\s\s\s\s\sEvent "Unknown event" does not exist.
        MESSAGE
      )
    end

    it "does not add the record to the repository" do
      expect { call }.not_to change { Talks.all.count }
    end
  end

  context "when the start time is in the wrong format" do
    let(:call) do
      described_class.(
        event_name: event.name,
        name: "My talk",
        start_time: "1900",
        end_time: "10:00am",
        speaker_name: speaker.name
      )
    end

    it "logs an error" do
      call
      expect(Log::Error).to have_received(:call).with(
        message: <<~MESSAGE.chomp
          Error: Talk is not valid.
          \s\s\s\s\s\s\sCould not understand start time "1900".
        MESSAGE
      )
    end

    it "does not add the record to the repository" do
      expect { call }.not_to change { Talks.all.count }
    end
  end

  context "when the end time is in the wrong format" do
    let(:call) do
      described_class.(
        event_name: event.name,
        name: "My talk",
        start_time: "9:00am",
        end_time: "1000",
        speaker_name: speaker.name
      )
    end

    it "logs an error" do
      call
      expect(Log::Error).to have_received(:call).with(
        message: <<~MESSAGE.chomp
          Error: Talk is not valid.
          \s\s\s\s\s\s\sCould not understand end time "1000".
        MESSAGE
      )
    end

    it "does not add the record to the repository" do
      expect { call }.not_to change { Talks.all.count }
    end
  end

  context "when the start time does not preceed the end time" do
    let(:call) do
      described_class.(
        event_name: event.name,
        name: "My talk",
        start_time: "10:00am",
        end_time: "9:00am",
        speaker_name: speaker.name
      )
    end

    it "logs an error" do
      call
      expect(Log::Error).to have_received(:call).with(
        message: <<~MESSAGE.chomp
          Error: Talk is not valid.
          \s\s\s\s\s\s\sThe start time must preceed the end time.
        MESSAGE
      )
    end

    it "does not add the record to the repository" do
      expect { call }.not_to change { Talks.all.count }
    end
  end

  context "when the talk is not added in sequential time order" do
    before do
      described_class.(
        event_name: event.name,
        name: "First talk",
        start_time: "10:00am",
        end_time: "11:00am",
        speaker_name: speaker.name
      )
    end

    let(:call) do
      described_class.(
        event_name: event.name,
        name: "My talk",
        start_time: "9:00am",
        end_time: "10:00am",
        speaker_name: speaker.name
      )
    end

    it "logs an error" do
      call
      expect(Log::Error).to have_received(:call).with(
        message: "Error: Talk is not valid.\n" \
          "       Talks must be entered in sequential order " \
          "and cannot overlap."
      )
    end

    it "does not add the record to the repository" do
      expect { call }.not_to change { Talks.all.count }
    end
  end

  context "when talk times overlap" do
    before do
      described_class.(
        event_name: event.name,
        name: "First talk",
        start_time: "9:00am",
        end_time: "10:00am",
        speaker_name: speaker.name
      )
    end

    let(:call) do
      described_class.(
        event_name: event.name,
        name: "My talk",
        start_time: "9:30am",
        end_time: "10:30am",
        speaker_name: speaker.name
      )
    end

    it "logs an error" do
      call
      expect(Log::Error).to have_received(:call).with(
        message: "Error: Talk is not valid.\n" \
          "       Talks must be entered in sequential order " \
          "and cannot overlap."
      )
    end

    it "does not add the record to the repository" do
      expect { call }.not_to change { Talks.all.count }
    end
  end

  context "when the speaker does not exist" do
    let(:call) do
      described_class.(
        event_name: event.name,
        name: "My talk",
        start_time: "9:00am",
        end_time: "10:00am",
        speaker_name: "Unknown speaker"
      )
    end

    it "logs an error" do
      call
      expect(Log::Error).to have_received(:call).with(
        message: <<~MESSAGE.chomp
          Error: Talk is not valid.
          \s\s\s\s\s\s\sSpeaker "Unknown speaker" does not exist.
        MESSAGE
      )
    end

    it "does not add the record to the repository" do
      expect { call }.not_to change { Talks.all.count }
    end
  end
end
