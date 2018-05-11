# frozen_string_literal: true

require 'circuitry'

module Circuitry
  Subscriber.prepend(
    Module.new do
      def handle_message_with_middleware(message, &block)
        middleware.invoke(message.topic.name, message.body) do
          handle_with_skip_delete(message, &block)
        end
      end

      def handle_with_skip_delete(message, &block)
        catch :skip_delete do
          handle_message(message, &block)
          delete_message(message)
        end
      end
    end
  )
end

module WithEvents
  module Aws
    class Topic
      def initialize(topic = nil)
        @topic = topic
      end

      def publish(message)
        Circuitry.publish(topic, message.serialize)
      end

      def subscribe(options = {}, &block)
        Circuitry.subscribe(options) do |message, topic_name|
          skip_delete unless positive_result?(topic_name, message, &block)
        end
      end

      private

      attr_reader :topic

      def positive_result?(topic_name, message)
        message = Message.from_sqs(message)
        valid_message?(message) && yield(message, topic_name)
      end

      def valid_message?(message)
        message.stream && message.event && message.identifier
      end

      def skip_delete
        throw :skip_delete
      end
    end
  end
end
