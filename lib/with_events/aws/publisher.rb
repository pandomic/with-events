# frozen_string_literal: true

require 'active_support/core_ext/module/delegation'

module WithEvents
  module Aws
    class Publisher
      def initialize(event, resource)
        @event = event
        @resource = resource
      end

      def publish
        return unless event.identifier && identifier
        topic.publish(message)
      end

      private

      attr_reader :event, :resource
      delegate :stream, to: :event

      def identifier
        @identifier ||= Invoker.new(event.identifier).invoke(resource)
      end

      def topic
        @topic ||= Topic.new(stream.topic)
      end

      def message
        @message ||= Message.new(event: event.name,
                                 stream: stream.name,
                                 identifier: identifier)
      end
    end
  end
end
