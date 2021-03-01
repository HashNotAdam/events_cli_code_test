# frozen_string_literal: true

require "interactors/log/fatal_error"
require "models/application_model"

RSpec.describe ApplicationModel do
  let(:model) do
    Class.new(ApplicationModel) do
      attr_accessor :name
      attr_accessor :age
      attr_accessor :location
    end
  end

  describe ".attributes" do
    it "returns the attributes on the model" do
      expect(model.attributes).to contain_exactly(:name, :age, :location)
    end
  end

  describe "#attributes" do
    it "returns the atrributes and their values" do
      instance = model.new
      instance.name = "Abc"
      instance.age = 12
      expect(instance.attributes).to eq(
        {
          name: "Abc",
          age: 12,
          location: nil,
        }
      )
    end
  end

  it "assigns the supplied values on initialize" do
    instance = model.new(name: "Abc", age: 12)
    expect(instance.attributes).to eq(
      {
        name: "Abc",
        age: 12,
        location: nil,
      }
    )
  end

  context "when positional arguments are supplied" do
    before { allow(Log::FatalError).to receive(:call) }

    it "raises a fatal error" do
      model.new("Abc")
      expect(Log::FatalError).to have_received(:call)
    end
  end

  context "when unexpected keyword arguments are supplied" do
    before do
      allow(Log::FatalError).to receive(:call).and_raise(ArgumentError)
    end

    it "raises a fatal error" do
      expect { model.new(name: "Abc", unknown: "Def") }.
        to raise_error ArgumentError
    end
  end
end
