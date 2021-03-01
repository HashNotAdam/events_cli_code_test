# frozen_string_literal: true

require "application"
require "interactors/documentation"
require "repositories/events"
require "repositories/speakers"
require "repositories/talks"

class Application
  class << self
    attr_accessor :inputs
  end

  def user_input
    self.class.instance_variable_get(:@inputs).shift || "EXIT"
  end
end

RSpec.describe Application do
  let(:bin_file) { "bin/events-manager" }
  let(:inputs) { [] }

  before { described_class.inputs = inputs }

  after do
    Events.clear_all
    Speakers.clear_all
    Talks.clear_all
  end

  it "presents the documentation" do
    expect { described_class.call }.
      to output(a_string_starting_with(Documentation.call)).
      to_stdout
  end

  context "when no command is given" do
    let(:inputs) { [""] }

    it "presents the documentation" do
      expect { described_class.call }.
        to output(
          a_string_matching(
            /.*#{Documentation.call}.*#{Documentation.call}/m
          )
        ).to_stdout
    end
  end

  it "creates and prints events with talks" do
    described_class.inputs = [
      "CREATE EVENT an_event",
      "CREATE SPEAKER John",
      "CREATE TALK an_event 'My First Talk' 9:00am 10:00am John",
      "CREATE EVENT new_event",
      "CREATE SPEAKER Sam",
      "CREATE TALK new_event 'hello world' 2:00pm 2:30pm Sam",
      "CREATE SPEAKER Bob",
      "CREATE TALK an_event 'code challenges' 2:00pm 2:30pm Bob",
      "CREATE SPEAKER Ben",
      "CREATE TALK an_event 'Joint Talk' 10:30am 12:00pm Ben",
      "PRINT TALKS an_event",
      "PRINT TALKS new_event",
    ]

    expect { described_class.call }.
      to output(
        a_string_including(
          "9:00am – 10:00am",
          "My First Talk presented by John",
          "10:30am – 12:00pm",
          "Joint Talk presented by Ben",
          "2:00pm – 2:30pm",
          "code challenges presented by Bob",
          "2:00pm – 2:30pm",
          "hello world presented by Sam"
        )
      ).to_stdout
  end
end
