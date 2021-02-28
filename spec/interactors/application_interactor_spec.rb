# frozen_string_literal: true

require "interactors/application_interactor"

RSpec.describe ApplicationInteractor do
  let(:sub_class) do
    Class.new(ApplicationInteractor) do
      string :arg

      def call
        $stdout.puts("Should not run")
      end
    end
  end

  it "creates an attr_reader for each parameter" do
    instance = sub_class.new(arg: "ABC")
    expect(instance.arg).to eq("ABC")
  end

  context "when passed a positional argument" do
    let(:sub_class) do
      Class.new(ApplicationInteractor) do
        def call
          $stdout.puts("Should not run")
        end
      end
    end

    it "prints an error to STDERR" do
      expect { sub_class.("ABC") }.
        to output(
          a_string_starting_with(
            "#{sub_class} called with positional arguments but interactors " \
            "only accept keyword arguments"
          )
        ).to_stderr
    end

    it "stops execution" do
      expect { sub_class.("ABC") }.
        not_to output(
          a_string_starting_with("Should not run")
        ).to_stdout
    end
  end

  context "when a keyword argument is passed" do
    let(:sub_class) do
      Class.new(ApplicationInteractor) do
        string :arg1
        string :arg2

        def call
          $stdout.puts("Should not run")
        end
      end
    end

    it "prints an error to STDERR" do
      expect { sub_class.(arg1: "ABC") }.
        to output(
          a_string_starting_with(
            "#{sub_class} expects to receive arguments :arg1, :arg2"
          )
        ).to_stderr
    end

    it "stops execution" do
      expect { sub_class.(arg1: "ABC") }.
        not_to output(
          a_string_starting_with("Should not run")
        ).to_stdout
    end
  end

  context "when an extra keyword argument is passed" do
    let(:sub_class) do
      Class.new(ApplicationInteractor) do
        string :arg

        def call
          $stdout.puts("Should not run")
        end
      end
    end

    it "prints an error to STDERR" do
      expect { sub_class.(arg: "ABC", arg2: "DEF", arg3: "GHI") }.
        to output(
          a_string_starting_with(
            "#{sub_class} received extra arguments :arg2, :arg3"
          )
        ).to_stderr
    end

    it "stops execution" do
      expect { sub_class.(arg: "ABC", arg2: "DEF", arg3: "GHI") }.
        not_to output(
          a_string_starting_with("Should not run")
        ).to_stdout
    end
  end

  context "when the supplied argument is of the wrong type" do
    let(:sub_class) do
      Class.new(ApplicationInteractor) do
        string :arg

        def call
          $stdout.puts("Should not run")
        end
      end
    end

    it "prints an error to STDERR" do
      expect { sub_class.(arg: 123) }.
        to output(
          a_string_starting_with(
            ":arg is expected to be a String but it is a Integer"
          )
        ).to_stderr
    end

    it "stops execution" do
      expect { sub_class.(arg: 123) }.
        not_to output(
          a_string_starting_with("Should not run")
        ).to_stdout
    end
  end
end
