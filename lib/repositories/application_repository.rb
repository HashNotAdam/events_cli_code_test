# frozen_string_literal: true

require "errors/invalid_record"
require "interactors/log/error"

class ApplicationRepository
  class << self
    def <<(record)
      incorrect_class_error unless record.instance_of?(record_class)
      invalid_record_error(record) unless record.valid?
      records << record
      record
    end

    def all
      records.dup.to_a.freeze
    end

    def clear_all
      @records = nil
    end

    def where(attribute, value)
      records.select { _1.public_send(attribute) == value }
    end

    private

    def incorrect_class_error
      Log::FatalError.(message: "New record should be of type #{record_class}")
    end

    def record_class
      const_get(name[...-1])
    end

    def invalid_record_error(record)
      raise(
        InvalidRecordError,
        "Error: #{record_class} is not valid.\n#{record.error_messages}"
      )
    end

    def records
      @records ||= []
    end
  end

  def initialize
    Log::FatalError.(message: "#{self.class.name} is an abstract class")
  end
end
