# frozen_string_literal: true

namespace :with_events do
  desc 'Run daily tasks'
  task daily: :environment do
    WithEvents::Trigger.new.call(WithEvents::Trigger::DAILY_APPEARANCE)
  end

  desc 'Run hourly tasks'
  task hourly: :environment do
    WithEvents::Trigger.new.call(WithEvents::Trigger::HOURLY_APPEARANCE)
  end
end
