# frozen_string_literal: true

require "application"
require "interactors/documentation"

class Application
  class << self
    attr_accessor :inputs
  end

  def user_input
    self.class.instance_variable_get(:@inputs).shift
  end
end

RSpec.describe Application do
  let(:bin_file) { "bin/events-manager" }
  let(:inputs) { %w[EXIT] }

  before { described_class.inputs = inputs }

  it "presents the documentation" do
    expect { described_class.call }.
      to output(a_string_starting_with(Documentation.call)).
      to_stdout
  end

  context "when no command is given" do
    let(:inputs) { ["", "EXIT"] }

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
      "CREATE TALK an_event 'My Talk' 9:00am 10:00am John",
      "CREATE EVENT new_event",
      "CREATE SPEAKER Sam",
      "CREATE TALK new_event 'hello world' 2:00pm 2:30pm Sam",
      "CREATE SPEAKER Bob",
      "CREATE TALK an_event 'code challenges' 2:00pm 2:30pm Bob",
      "CREATE SPEAKER Ben",
      "CREATE TALK an_event 'Joint Talk' 10:30am 12:00am Ben",
      "PRINT TALKS an_event",
      "PRINT TALKS new_event",
      "EXIT",
    ]
    expect { described_class.call }.
      to output(
        a_string_including(<<~STRING)
          Enter command:
          PRINT TALKS new_event

          9:00am - 10:00am
            My First Talk presented by John
          10:30am - 12:00am
            Joint Talk presented by Ben
          2:00pm - 2:30pm
            code challenges presented by Bob

          Enter command:
          PRINT TALKS new_event

          2:00pm - 2:30pm
            hello world presented by Sam
        STRING
      ).to_stdout
  end
end
