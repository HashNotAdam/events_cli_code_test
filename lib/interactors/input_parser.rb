# frozen_string_literal: true

require "interactors/application_interactor"
require "interactors/documentation"
require "interactors/exit"

class InputParser < ApplicationInteractor
  param :input

  def call
    return nil if input.empty?

    segments = split_input(input)
    interactor = interactor_class(segments)
    {
      interactor: interactor,
      arguments: arguments(interactor, segments),
    }
  end

  private

  def split_input(input)
    escape_strings(input).split.each_with_object([]) do |piece, array|
      array << unescape_string(piece)
    end
  end

  STRING_ESCAPE_CHARACTER = "<string>"

  def escape_strings(input)
    dup_input = input.dup
    string_matches = dup_input.match(/('[^']+')/)
    return dup_input if string_matches.nil?

    string_matches.to_a[1..].each do
      escaped = _1.gsub(" ", STRING_ESCAPE_CHARACTER)
      dup_input.sub!(_1, escaped)
    end

    dup_input.tr("'", "")
  end

  def unescape_string(string)
    string.gsub(STRING_ESCAPE_CHARACTER, " ")
  end

  def interactor_class(input_array)
    class_name = input_array[0].downcase.capitalize

    if !input_array[1].nil? && input_array[1].match?(/^[A-Z]+$/)
      class_name += input_array[1].downcase.capitalize
    end

    Object.const_get(class_name)
  end

  def arguments(interactor, input_array)
    return {} if interactor.parameters.nil?

    command_length = interactor.name.match(/([A-Z])/).length
    args = input_array[command_length..]
    interactor.parameters.zip(args).to_h
  end
end
