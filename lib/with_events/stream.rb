# frozen_string_literal: true

module WithEvents
  class Stream
    attr_reader :name, :klass, :events, :watchers, :topic, :subscribe

    def initialize(name, klass, options = {})
      @name = name
      @klass = klass
      @events = []
      @watchers = {}
      @topic = options[:topic]
      @configuration = {}
      @subscribe = options[:subscribe]

      self.class.streams << self
    end

    def event(name, options = {})
      events <<
        Event.new(name, klass, options.merge(configuration).merge(stream: self))
    end

    def configure_all(options = {})
      @configuration = options
    end

    def on(name, &block)
      watchers[name] ||= []
      watchers[name] << block
    end

    def notify(event, resource)
      notify_sqs(event, resource) if topic
      notify_watchers(event, resource)
    end

    def notify_watchers(event, resource)
      return if watchers[event.name].nil?
      watchers[event.name].each { |watcher| resource.instance_exec(&watcher) }
    end

    class << self
      attr_accessor :subscribed

      def streams
        @streams ||= []
      end

      def find_or_initialize(name, klass, options = {})
        find(name) || new(name, klass, options)
      end

      def find(name)
        streams.find { |s| s.name == name }
      end

      def subscribe
        return if subscribed || !streams.find { |s| s.topic && s.subscribe }
        self.subscribed = true

        Aws::Topic.new.subscribe(async: true, timeout: 0) do |message, topic|
          selected = stream_events(message, topic)
          selected.each { |event| notify_event(event, message) }.size.positive?
        end
      end

      private

      def stream_events(message, topic_name)
        stream = find(message.stream.to_sym)
        return [] unless stream&.subscribe && stream&.topic&.to_s == topic_name
        stream.events.select { |event| valid_event?(event, message) }
      end

      def valid_event?(event, message)
        event.finder && event.callback && message.event.to_sym == event.name
      end

      def notify_event(event, message)
        context = Invoker.new(event.finder)
                         .invoke(TOPLEVEL_BINDING.eval('self'), message)
        event.stream.notify_watchers(event, context)
        Invoker.new(event.callback).invoke(context)
      end
    end

    private

    attr_reader :configuration

    def notify_sqs(event, resource)
      Aws::Publisher.new(event, resource).publish
    end
  end
end
