# frozen_string_literal: true

require "interactors/application_interactor"
require "interactors/create_event"
require "interactors/documentation"
require "interactors/exit"

class InputParser < ApplicationInteractor
  param :input

  def call
    return nil if input.empty?

    segments = split_input(input)
    interactor = interactor_class(segments)
    return nil if interactor.nil?

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
    string_matches = quote_matches(dup_input)
    return dup_input if string_matches.empty?

    string_matches.each do
      escaped = _1.gsub(" ", STRING_ESCAPE_CHARACTER)
      dup_input.sub!(_1, escaped)
    end

    remove_quotes(dup_input)
  end

  def quote_matches(string)
    matches_to_a(string, /('[^']+')/).
      concat(matches_to_a(string, /("[^"]+")/))
  end

  def matches_to_a(string, regex)
    string.match(regex).to_a[1..].to_a
  end

  def remove_quotes(string)
    string.gsub(/'([^\s]+)'/, '\1').gsub(/"([^\s]+)"/, '\1')
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
  rescue NameError
  end

  def arguments(interactor, input_array)
    return {} if interactor.parameters.nil?

    command_length = interactor.name.match(/([A-Z])/).length
    args = input_array[command_length..]
    interactor.parameters.zip(args).to_h
  end
end
