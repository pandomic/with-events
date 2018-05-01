# frozen_string_literal: true

require 'sidekiq'

module WithEvents
  class Trigger
    include Sidekiq::Worker

    HOURLY_APPEARANCE = :hourly
    DAILY_APPEARANCE = :daily

    sidekiq_options retry: false

    def perform(appearance)
      Stream.streams.each do |stream|
        process_stream(stream, appearance.to_sym)
      end

      reraise_exceptions
    end

    private

    def process_stream(stream, appearance)
      stream.events.each do |event|
        next unless valid_event?(event, appearance)
        event.options[:batch].each do |resource|
          call(event, resource) if may_call?(event, resource)
        end
      end
    end

    # rubocop:disable Lint/RescueWithoutErrorClass
    def call(event, resource)
      resource.public_send("#{event.name}!")
    rescue => e
      exceptions << e
    end

    def may_call?(event, resource)
      resource.public_send("may_#{event.name}?")
    rescue => e
      exceptions << e
    end
    # rubocop:enable Lint/RescueWithoutErrorClass

    def valid_batch?(event)
      event.options[:batch].is_a?(Enumerable)
    end

    def valid_event?(event, appearance)
      background_event?(event) &&
        valid_appearance?(event, appearance) &&
        valid_batch?(event)
    end

    def background_event?(event)
      event.options[:background]
    end

    def valid_appearance?(event, appearance)
      [HOURLY_APPEARANCE, DAILY_APPEARANCE]
        .include?(event.options[:appearance]) &&
        event.options[:appearance] == appearance
    end

    def exceptions
      @exceptions ||= []
    end

    def reraise_exceptions
      exceptions.each do |e|
        Thread.new { raise e }
      end
    end
  end
end
