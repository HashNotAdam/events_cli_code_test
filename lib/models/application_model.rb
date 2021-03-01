# frozen_string_literal: true

require "interactors/log/fatal_error"

class ApplicationModel
  class << self
    def attr_accessor(name)
      attributes << name
      super
    end

    def attributes
      @attributes ||= []
    end
  end

  def initialize(*args, **keyword_args)
    validate_args(args)
    validate_no_extra_keys(keyword_args)
    assign_attributes(keyword_args)
  end

  def attributes
    self.class.attributes.each_with_object({}) do |attribute, hash|
      hash[attribute] = public_send(attribute)
    end
  end

  def errors
    @errors ||= []
  end

  def error_messages
    errors.map { "       #{_1}." }.join("\n")
  end

  def valid?
    errors.empty?
  end

  private

  def validate_args(args)
    return if args.empty?

    Log::FatalError.(
      message: "#{self.class} called with positional arguments " \
        "but models only accept keyword arguments"
    )
  end

  def validate_no_extra_keys(keyword_args)
    expected_keys = self.class.attributes
    supplied_keys = keyword_args.keys
    extra_keys = supplied_keys - expected_keys
    return if extra_keys.empty?

    Log::FatalError.(
      message: "#{self.class} received extra arguments " \
        ":#{extra_keys.map(&:to_s).join(", :")}"
    )
  end

  def assign_attributes(keyword_args)
    keyword_args.each do |attribute, value|
      public_send("#{attribute}=", value)
    end
  end
end
