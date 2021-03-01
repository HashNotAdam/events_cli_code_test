# frozen_string_literal: true

require "interactors/log/error"

class ApplicationRepository
  class << self
    def <<(record)
      incorrect_class_error unless record.instance_of?(record_class)
      invalid_record_error(record) unless record.valid?
      records << record
    end

    def where(attribute, value)
      records.select { _1.public_send(attribute) == value }
    end

    private

    def incorrect_class_error
      error("New record should be of type #{record_class}")
    end

    def record_class
      const_get(name[...-1])
    end

    def invalid_record_error(record)
      error("#{record.class.name} is not valid")
    end

    def error(message)
      Log::FatalError.(message: message)
    end

    def records
      @records ||= []
    end
  end

  def initialize
    self.class.error("#{self.class.name} is an abstract class")
  end
end
