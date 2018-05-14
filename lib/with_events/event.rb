# frozen_string_literal: true

module WithEvents
  class Event
    attr_reader :name, :identifier, :options, :callback,
                :condition, :stream, :finder

    ##
    # ==Options:
    #
    # +name+ - event name
    # +klass+ - resource class name
    # +options[:condition]+ - condition to check whether event can be triggered
    # +options[:callback]+ - callback to invoke on event
    # +options[:stream]+ - stream object event belongs to
    # +options[:identifier]+ - resource identifier (symbol, Proc or Class)
    # +options[:finder]+ - resource finder (symbol, Proc or Class)
    # +options[:subscribe]+ - subscribe to SQS queue
    def initialize(name, klass, options = {})
      @name = name
      @klass = klass
      @options = options
      @condition = options[:condition]
      @callback = options[:callback]
      @stream = options[:stream]
      @identifier = options[:identifier]
      @finder = options[:finder]

      define_condition
      define_callback
    end

    private

    attr_reader :klass

    def define_condition
      return unless condition

      klass.instance_exec(self) do |event|
        define_method("#{event.name}?") do
          return false unless event.condition
          Invoker.new(event.condition).invoke(self)
        end
      end
    end

    def define_callback
      klass.instance_exec(self) do |event|
        define_method("#{event.name}!") do
          event.stream.notify(event, self)
          return if event.stream.subscribe || !event.callback
          Invoker.new(event.callback).invoke(self)
        end
      end
    end
  end
end
