# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'with_events/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'with_events'
  s.version     = WithEvents::VERSION
  s.authors     = ['Vlad Gramuzov']
  s.email       = ['vlad.gramuzov@gmail.com']
  s.homepage    = 'http://google.com'
  s.summary     = 'Summary of Rails::Events.'
  s.description = 'Description of Rails::Events.'
  s.license     = 'MIT'

  s.files = Dir[
    '{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md'
  ]

  s.add_dependency 'activesupport', '~> 4.2.7'
  s.add_dependency 'require_all', '~> 1.4.0'
  s.add_dependency 'sidekiq', '~> 3.5.3'

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop', '~> 0.51.0'
  s.add_development_dependency 'sqlite3'
end
