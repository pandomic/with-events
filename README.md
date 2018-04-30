# WithEvents
A simple events system for Ruby apps.

## Dependencies
* Ruby >= 2.3.3
* Rake >= 12.3.1
* Activesupport >= 4.2.7
* Sidekiq >= 3.5.3

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rails-events'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install rails-events
```

## Usage

### Basic Usage
```ruby
require 'with_events'

class MyHeroClass
  include WithEvents
  
  stream :my_lovely_stream do
    event :game_over,
          condition: :really_game_over?,
          callback: :call_me_if_game_over
  end
  
  def really_game_over?
    true
  end
  
  def call_me_if_game_over
    puts 'Game over'
  end
end

hero = MyHeroClass.new
hero.game_over! if hero.game_over?
```

### Using with daily/hourly rake triggers

You may want to automate a bit the process of asking resources if
they are ready to trigger events (by calling `#may_*?`). This can
be easily done by using `background: true` 
with `appearance: :daily # or hourly` options.

`appearance` option sets by which rake task your event may
be processed.

```ruby
require 'with_events'

class MyHeroClass
  include WithEvents
  
  stream :my_lovely_stream do
    event :game_over,
          condition: :really_game_over?,
          callback: :call_me_if_game_over,
          background: true,
          appearance: :daily # or :hourly
  end
  
  def really_game_over?
    true
  end
  
  def call_me_if_game_over
    puts 'Game over'
  end
end
```
Schedule for hourly/daily execution
```bash
$ rake with_events:daily 
$ rake with_events:hourly 
```

### "Third-party" subscriptions

It is also possible to subscribe to events not only by using
a `callback` option:

```ruby
WithEvents::Stream.find(:my_lovely_stream).on(:game_over) do
  # ...
end
```

### Supported invokable types
* Proc
* Symbol
* Class

You may use them as `condition` or `callback` arguments.

```ruby
class CallbackClass
  def call(resource, *arguments)
    puts 'Game over'
  end
end

class MyHeroClass
  include WithEvents
  
  stream :my_lovely_stream do
    event :game_over,
          condition: :really_game_over?,
          callback: CallbackClass
          
    event :you_won,
          condition: -> { really_won? },
          callback: CallbackClass
  end
  
  def really_won?
      false
    end
  
  def really_game_over?
    true
  end
end

```

## Contributing
If you are going to contribute to this repo, please follow these simple rules:
* Cover you wrote with specs
* Check you wrote with Rubocop
* Use Karma-style comit messages

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
