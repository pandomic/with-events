# frozen_string_literal: true

require 'sidekiq'

module WithEvents
  class Worker
    include WithEvents::Validator
    include Sidekiq::Worker

    sidekiq_options retry: false

    def perform(stream, event_name, appearance)
      events(stream, event_name, appearance).each do |event|
        stream(stream).batch.call.each do |resource|
          call(event, resource) if may_call?(event, resource)
        end
      end

      reraise_last_exception
    end

    private

    # rubocop:disable Lint/RescueWithoutErrorClass
    def call(event, resource)
      resource.public_send("#{event.name}!")
    rescue => e
      exceptions << e
    end

    def may_call?(event, resource)
      resource.public_send("#{event.name}?")
    rescue => e
      exceptions << e
    end
    # rubocop:enable Lint/RescueWithoutErrorClass

    def stream(stream)
      @stream ||= Stream.find(stream.to_sym)
    end

    def events(stream, name, appearance)
      return [] unless stream(stream)

      @events ||= stream(stream).events.select do |event|
        event.name == name.to_sym && valid_event?(event, appearance)
      end
    end

    def exceptions
      @exceptions ||= []
    end

    def reraise_last_exception
      raise exceptions.last if exceptions.size.positive?
    end
  end
end
