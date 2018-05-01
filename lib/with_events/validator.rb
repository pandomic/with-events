# frozen_string_literal: true

module WithEvents
  module Validator
    HOURLY_APPEARANCE = :hourly
    DAILY_APPEARANCE = :daily

    def valid_event?(event, appearance)
      background_event?(event) &&
        valid_appearance?(event, appearance) &&
        valid_batch?(event)
    end

    private

    def valid_batch?(event)
      event.options[:batch].is_a?(Enumerable)
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
