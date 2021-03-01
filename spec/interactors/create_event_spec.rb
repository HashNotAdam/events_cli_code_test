# frozen_string_literal: true

require "interactors/create_event"
require "interactors/log/info"
require "repositories/events"

RSpec.describe CreateEvent do
  before { allow(Log::Info).to receive(:call) }

  it "adds a new event to the Events repository" do
    expect { described_class.(name: "Abc") }.
      to change { Events.all.count }.by(1)
  end

  it "logs an acknowledgement" do
    described_class.(name: "Abc")
    expect(Log::Info).to have_received(:call).
      with(message: %(Event "Abc" has been created))
  end
end
