# frozen_string_literal: true

module WithEvents
  class Invoker
    def initialize(callable)
      @callable = callable
    end

    def invoke(context, *args)
      return context.instance_exec(*args, &callable) if proc?
      return callable.new.call(context, *args) if class?
      return context.public_send(callable, *args) if symbol?(context)

      raise NotImplementedError, 'Argument can not be invoked'
    end

    private

    attr_reader :callable

    def proc?
      callable.is_a?(Proc)
    end

    def class?
      callable.is_a?(Class) && callable.instance_methods.include?(:call)
    end

    def symbol?(context)
      callable.is_a?(Symbol) && context.respond_to?(callable)
    end
  end
end
