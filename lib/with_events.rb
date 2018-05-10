# frozen_string_literal: true

require 'active_support/concern'
require 'require_all'

module WithEvents
  extend ActiveSupport::Concern

  autoload_all __dir__ + '/with_events'

  module ClassMethods
    def stream(name, options = {}, &block)
      Stream.find_or_initialize(name, self, options).instance_exec(&block)
    end
  end
end
