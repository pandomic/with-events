# frozen_string_literal: true

module WithEvents
  class Trigger
    include WithEvents::Validator

    def call(appearance)
      Stream.streams.each do |stream|
        process_stream(stream, appearance.to_sym)
      end
    end

    private

    def process_stream(stream, appearance)
      stream.events.each do |event|
        next unless valid_event?(event, appearance)
        WithEvents::Worker.perform_async(stream.name, event.name, appearance)
      end
    end
  end
end
