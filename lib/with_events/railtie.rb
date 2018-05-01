# frozen_string_literal: true

require 'active_support/railtie'

module WithEvents
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/with_events/with_events_tasks.rake'
    end
  end
end
