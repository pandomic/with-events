# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'

module WithEvents
  module Aws
    class Message
      attr_reader :event, :stream, :identifier

      alias id identifier

      def initialize(options = {})
        @options = options.with_indifferent_access
        @event = @options[:event]
        @stream = @options[:stream]
        @identifier = @options[:identifier]
      end

      def serialize
        options.deep_transform_keys { |key| key.to_s.camelize(:lower) }
      end

      def self.from_sqs(options = {})
        new(options.deep_transform_keys { |key| key.to_s.underscore })
      end

      private

      attr_reader :options
    end
  end
end
