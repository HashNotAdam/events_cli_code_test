# frozen_string_literal: true

require "models/application_model"
require "presenters/talk_presenter"
require "repositories/events"
require "repositories/speakers"
require "time"

class Talk < ApplicationModel
  attr_accessor :event_name
  attr_accessor :name
  attr_accessor :start_time
  attr_accessor :end_time
  attr_accessor :speaker_name

  def self.now
    @now ||= Time.now
  end

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
    parsed_start = validate_start_time
    parsed_end = validate_end_time
    return if parsed_start.nil? || parsed_end.nil?

    self.start_time = parsed_start
    self.end_time = parsed_end

    validate_start_preceeds_end
    validate_talks_do_not_overlap
  end

  def validate_start_time
    time = parse_time(start_time)
    return time unless time.nil?

    time_parse_error("start time", start_time)
    nil
  end

  def validate_end_time
    time = parse_time(end_time)
    return time unless time.nil?

    time_parse_error("end time", end_time)
    nil
  end

  def parse_time(time)
    Time.parse(time, self.class.now)
  rescue ArgumentError
  end

  def time_parse_error(attribute, value)
    errors << %(Could not understand #{attribute} "#{value}")
  end

  def validate_start_preceeds_end
    return if (end_time - start_time).positive?

    errors << "The start time must preceed the end time"
  end

  def validate_talks_do_not_overlap
    Talks.where(:event_name, event_name).each do |another_talk|
      next unless overlaps?(another_talk)

      presenter = TalkPresenter.new(another_talk)
      errors <<
        "Talk overlaps with #{another_talk.name} (#{presenter.schedule})"
    end
  end

  def overlaps?(another_talk)
    time_range = (another_talk.start_time + 1)..(another_talk.end_time - 1)
    return true if time_range.include?(start_time)
    return true if time_range.include?(end_time)

    false
  end

  def validate_speaker
    speakers = Speakers.where(:name, speaker_name)
    return unless speakers.empty?

    errors << %(Speaker "#{speaker_name}" does not exist)
  end
end
