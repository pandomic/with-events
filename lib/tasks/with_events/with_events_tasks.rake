# frozen_string_literal: true

namespace :with_events do
  desc 'Run daily tasks'
  task :daily do
    WithEvents::Trigger.perform_async(WithEvents::Trigger::DAILY_APPEARANCE)
  end

  desc 'Run hourly tasks'
  task :daily do
    WithEvents::Trigger.perform_async(WithEvents::Trigger::HOURLY_APPEARANCE)
  end
end
