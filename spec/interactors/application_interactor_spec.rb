# frozen_string_literal: true

require "interactors/application_interactor"
require "interactors/log/error"

RSpec.describe ApplicationInteractor do
  let(:sub_class) do
    Class.new(ApplicationInteractor) do
      param :arg

      def call
        raise "Should not run"
      end
    end
  end

  before { allow(Log::Error).to receive(:call) }

  it "creates an attr_reader for each parameter" do
    instance = sub_class.new(arg: "ABC")
    expect(instance.arg).to eq("ABC")
  end

  context "when passed a positional argument" do
    it "logs an error" do
      sub_class.("ABC")
      expect(Log::Error).to have_received(:call).with(
        message: "#{sub_class} called with positional arguments but " \
          "interactors only accept keyword arguments"
      )
    end

    it "stops execution" do
      expect { sub_class.("ABC") }.not_to raise_exception
    end
  end

  context "when a keyword argument is passed" do
    let(:sub_class) do
      Class.new(ApplicationInteractor) do
        param :arg1
        param :arg2

        def call
          $stdout.puts("Should not run")
        end
      end
    end

    it "logs an error" do
      sub_class.(arg1: "ABC")
      expect(Log::Error).to have_received(:call).with(
        message: "#{sub_class} expects to receive arguments :arg1, :arg2"
      )
    end

    it "stops execution" do
      expect { sub_class.(arg1: "ABC") }.not_to raise_exception
    end
  end

  context "when an extra keyword argument is passed" do
    let(:sub_class) do
      Class.new(ApplicationInteractor) do
        param :arg

        def call
          $stdout.puts("Should not run")
        end
      end
    end

    it "logs an error" do
      sub_class.(arg: "ABC", arg2: "DEF", arg3: "GHI")
      expect(Log::Error).to have_received(:call).with(
        message: "#{sub_class} received extra arguments :arg2, :arg3"
      )
    end

    it "stops execution" do
      expect { sub_class.(arg: "ABC", arg2: "DEF", arg3: "GHI") }.
        not_to raise_exception
    end
  end
end
