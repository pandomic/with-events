# frozen_string_literal: true

module WithEvents
  class Stream
    attr_reader :name, :klass, :events, :watchers, :batch

    def initialize(name, klass, options = {})
      @name = name
      @klass = klass
      @events = []
      @watchers = {}
      @batch = options[:batch]

      self.class.streams << self
    end

    def event(name, options = {})
      events << Event.new(name, klass, options.merge(stream: self))
    end

    def on(name, &block)
      watchers[name] ||= []
      watchers[name] << block
    end

    def notify(name, resource)
      return if watchers[name].nil?
      watchers[name].each { |watcher| resource.instance_exec(&watcher) }
    end

    class << self
      def streams
        @streams ||= []
      end

      def find_or_initialize(name, klass, options = {})
        find(name) || new(name, klass, options)
      end

      def find(name)
        streams.find { |s| s.name == name }
      end
    end
  end
end
