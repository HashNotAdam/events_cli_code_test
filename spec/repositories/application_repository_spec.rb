# frozen_string_literal: true

require "errors/invalid_record"
require "interactors/log/fatal_error"
require "models/application_model"
require "repositories/application_repository"

RSpec.describe ApplicationRepository do
  let(:repository) do
    klass = Class.new(described_class)
    Object.const_set("Records", klass)
    klass
  end

  let(:model) do
    klass = Class.new(ApplicationModel) do
      attr_accessor :name
      attr_accessor :age
    end
    Object.const_set("Record", klass)
    klass
  end

  before do
    allow(Log::FatalError).to receive(:call)
  end

  after do
    %w[Record Records].each { Object.__send__(:remove_const, _1) }
  end

  describe ".<<" do
    it "adds the record to the records array" do
      record = model.new
      repository << record
      expect(repository.__send__(:records)).to contain_exactly(record)
    end

    context "when the record is of the wrong type" do
      let(:model) do
        klass = Class.new(ApplicationModel)
        Object.const_set("DifferentRecord", klass)
        Object.const_set("Record", Class.new)
        klass
      end

      after { Object.__send__(:remove_const, "DifferentRecord") }

      it "raises an fatal error" do
        record = model.new
        repository << record
        expect(Log::FatalError).to have_received(:call).
          with(message: "New record should be of type Record")
      end
    end

    context "when the record is not valid" do
      let(:model) do
        klass = Class.new(ApplicationModel) do
          def valid? = false
        end
        Object.const_set("Record", klass)
        klass
      end

      it "raises an fatal error" do
        record = model.new
        expect { repository << record }.to raise_error InvalidRecordError
      end
    end
  end

  describe ".all" do
    let(:records) do
      [
        model.new(name: "Abc", age: 12),
        model.new(name: "Def", age: 12),
        model.new(name: "Abc", age: 23),
      ]
    end

    before do
      records.each { repository << _1 }
    end

    it "returns all records in the repository" do
      expect(repository.all).to contain_exactly(*records)
    end

    it "returns a copy of the records, not a reference" do
      records = repository.all
      expect(repository.all).not_to be(records)
    end

    it "freezes the array to signal it should not be modified" do
      expect(repository.all).to be_frozen
    end
  end

  describe ".clear_all" do
    let(:records) do
      [
        model.new(name: "Abc", age: 12),
        model.new(name: "Def", age: 12),
        model.new(name: "Abc", age: 23),
      ]
    end

    before do
      records.each { repository << _1 }
    end

    it "deletes all records" do
      expect { repository.clear_all }.
        to change { repository.all.count }.to(0)
    end
  end

  describe ".where" do
    let(:records) do
      [
        model.new(name: "Abc", age: 12),
        model.new(name: "Def", age: 12),
        model.new(name: "Abc", age: 23),
      ]
    end

    before do
      records.each { repository << _1 }
    end

    it "searches all records to find those with the required attribute value" do
      expect(repository.where(:name, "Abc")).
        to contain_exactly(records[0], records[2])
    end

    context "when there are no matches" do
      it "returns an empty array" do
        expect(repository.where(:name, "Ghi")).to eq([])
      end
    end
  end
end
