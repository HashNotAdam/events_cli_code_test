# frozen_string_literal: true

require "interactors/log/error"

class ApplicationInteractor
  class << self
    def call(*args, **keyword_args)
      new(*args, **keyword_args).call
    rescue HaltInteraction
    rescue StandardError => e
      $stderr.write(<<~MESSAGE)
        An unexpected error has occurred: #{e.message}
        #{e.backtrace.first}
      MESSAGE
    end

    def string(parameter_name)
      parameter(parameter_name, :string)
    end

    def expected_keyword_args
      @fields&.keys
    end

    private

    def parameter(name, type)
      @fields ||= {}
      @fields[name] = {
        type: type,
      }
      attr_reader name
    end
  end

  def initialize(*args, **keyword_args)
    validate_args(args)
    validate_keyword_args(keyword_args)
    assign_arguments(keyword_args)
    validate_argument_types
  end

  private

  def validate_args(args)
    return if args.empty?

    error(
      "#{self.class} called with positional arguments but interactors only " \
      "accept keyword arguments"
    )
  end

  def validate_keyword_args(keyword_args)
    return if self.class.expected_keyword_args.nil?

    validate_no_missing_keys(keyword_args)
    validate_no_extra_keys(keyword_args)
  end

  def validate_no_missing_keys(keyword_args)
    expected_keys = self.class.expected_keyword_args
    supplied_keys = keyword_args.keys
    missing_keys = expected_keys - supplied_keys
    return if missing_keys.empty?

    error(
      "#{self.class} expects to receive arguments " \
      ":#{expected_keys.map(&:to_s).join(", :")}"
    )
  end

  def validate_no_extra_keys(keyword_args)
    expected_keys = self.class.expected_keyword_args
    supplied_keys = keyword_args.keys
    extra_keys = supplied_keys - expected_keys
    return if extra_keys.empty?

    error(
      "#{self.class} received extra arguments " \
      ":#{extra_keys.map(&:to_s).join(", :")}"
    )
  end

  def assign_arguments(keyword_args)
    keyword_args.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def validate_argument_types
    self.class.instance_variable_get(:@fields)&.each do |name, options|
      value = instance_variable_get("@#{name}")
      type_class = Object.const_get(options[:type].to_s.capitalize)
      next if value.is_a?(type_class)

      error(
        ":#{name} is expected to be a #{type_class} but it is a #{value.class}"
      )
    end
  end

  def error(message)
    Log::Error.(message: message)
    raise HaltInteraction
  end
end

class HaltInteraction < StandardError; end
