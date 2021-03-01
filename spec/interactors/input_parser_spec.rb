# frozen_string_literal: true

require "interactors/input_parser"
require "interactors/documentation"
require "interactors/create_talk"
require "interactors/exit"

RSpec.describe InputParser do
  context "when there is a single word command" do
    it "splits input into a command and arguments" do
      input = "EXIT"
      expect(described_class.(input: input)).to eq(
        {
          interactor: Exit,
          arguments: {},
        }
      )
    end
  end

  context "when there is a multi-word command" do
    it "splits input into a command and arguments" do
      input = "CREATE TALK an_event 'My Talk' 9:00am 10:00am John"
      expect(described_class.(input: input)).to eq(
        {
          interactor: CreateTalk,
          arguments: {
            event_name: "an_event",
            name: "My Talk",
            start_time: "9:00am",
            end_time: "10:00am",
            speaker_name: "John",
          },
        }
      )
    end
  end

  context "when an argument is wrapped in single-quotes" do
    it "treats everything inside the quotes as one argument" do
      input = "CREATE TALK an_event 'My Talk' 9:00am 10:00am 'John Smith'"
      expect(described_class.(input: input)).to eq(
        {
          interactor: CreateTalk,
          arguments: {
            event_name: "an_event",
            name: "My Talk",
            start_time: "9:00am",
            end_time: "10:00am",
            speaker_name: "John Smith",
          },
        }
      )
    end
  end

  context "when an attribute is wrapped in double-quotes" do
    it "treats everything inside the quotes as one argument" do
      input = %(CREATE TALK an_event "John's Talk" 9:00am 10:00am "John Smith")
      expect(described_class.(input: input)).to eq(
        {
          interactor: CreateTalk,
          arguments: {
            event_name: "an_event",
            name: "John's Talk",
            start_time: "9:00am",
            end_time: "10:00am",
            speaker_name: "John Smith",
          },
        }
      )
    end
  end

  context "when no input is given" do
    it "displays the documentation in an error message" do
      expect(described_class.(input: "")).to be_nil
    end
  end
end
