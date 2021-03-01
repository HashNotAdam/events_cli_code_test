# frozen_string_literal: true

require "models/application_model"
require "repositories/events"
require "repositories/speakers"
require "time"

class Talk < ApplicationModel
  attr_accessor :event_name
  attr_accessor :name
  attr_accessor :start_time
  attr_accessor :end_time
  attr_accessor :speaker_name

  def valid?
    validate
    super
  end

  private

  def validate
    validate_event
    validate_times
    validate_speaker
  end

  def validate_event
    events = Events.where(:name, event_name)
    return unless events.empty?

    errors << %(Event "#{event_name}" does not exist)
  end

  def validate_times
    now = Time.now
    parsed_start = validate_start_time(now)
    parsed_end = validate_end_time(now)
    return if parsed_start.nil? || parsed_end.nil?

    validate_start_preceeds_end(parsed_start, parsed_end)
    validate_sequential_time_order(parsed_start, now)
  end

  def validate_start_time(now)
    time = parse_time(start_time, now)
    return time unless time.nil?

    time_parse_error("start time", start_time)
    nil
  end

  def validate_end_time(now)
    time = parse_time(end_time, now)
    return time unless time.nil?

    time_parse_error("end time", end_time)
    nil
  end

  def parse_time(time, now)
    Time.parse(time, now)
  rescue ArgumentError
  end

  def time_parse_error(attribute, value)
    errors << %(Could not understand #{attribute} "#{value}")
  end

  def validate_start_preceeds_end(parsed_start, parsed_end)
    return if (parsed_end - parsed_start).positive?

    errors << "The start time must preceed the end time"
  end

  def validate_sequential_time_order(parsed_start, now)
    last_talk = Talks.all[-1]
    return if last_talk.nil?

    last_parsed_end = parse_time(last_talk.end_time, now)
    return if last_parsed_end <= parsed_start

    errors << "Talks must be entered in sequential order and cannot overlap"
  end

  def validate_speaker
    speakers = Speakers.where(:name, speaker_name)
    return unless speakers.empty?

    errors << %(Speaker "#{speaker_name}" does not exist)
  end
end
