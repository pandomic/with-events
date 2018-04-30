# frozen_string_literal: true

require 'sidekiq/worker'

module WithEvents
  class Trigger
    include Sidekiq::Worker

    HOURLY_APPEARANCE = :hourly
    DAILY_APPEARANCE = :daily

    def perform(appearance)
      Stream.streams.each do |stream|
        stream.events.each do |event|
          next unless valid_event?(event, appearance)
          call(event) if may_call?(event)
        end
      end
    end

    private

    def call(event)
      event.public_send("#{event.name}!")
    end

    def may_call?(event)
      event.public_send("may_#{event.name}?")
    end

    def valid_event?(event, appearance)
      background_event?(event) && valid_appearance?(event, appearance)
    end

    def background_event?(event)
      event.options[:background]
    end

    def valid_appearance?(event, appearance)
      [HOURLY_APPEARANCE, DAILY_APPEARANCE]
        .include?(event.options[:appearance]) &&
        event.options[:appearance] == appearance
    end
  end
end
