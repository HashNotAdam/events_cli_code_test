# frozen_string_literal: true

require "models/application_model"
require "presenters/application_presenter"

RSpec.describe ApplicationPresenter do
  let(:presenter) do
    Class.new(ApplicationPresenter) do
      def full_name
        "#{object.first_name} #{object.last_name}"
      end
    end
  end
  let(:model) do
    Class.new(ApplicationModel) do
      attr_accessor :first_name
      attr_accessor :last_name
    end
  end
  let(:record) { model.new(first_name: "Abc", last_name: "Def") }

  it "handles any messages for which it has an appropriate method" do
    subject = presenter.new(record)
    expect(subject.full_name).to eq("Abc Def")
  end

  it "passes on any messages it can't handle to the object" do
    subject = presenter.new(record)
    expect(subject.first_name).to eq("Abc")
  end
end
