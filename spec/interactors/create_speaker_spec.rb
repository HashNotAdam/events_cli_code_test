# frozen_string_literal: true

require "interactors/create_speaker"
require "interactors/log/info"
require "repositories/speakers"

RSpec.describe CreateSpeaker do
  before { allow(Log::Info).to receive(:call) }

  after { Speakers.clear_all }

  it "adds a new event to the Speakers repository" do
    expect { described_class.(name: "Abc") }.
      to change { Speakers.all.count }.by(1)
  end

  it "logs an acknowledgement" do
    described_class.(name: "Abc")
    expect(Log::Info).to have_received(:call).
      with(message: %(Speaker "Abc" has been created))
  end
end
