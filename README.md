![Build status](https://travis-ci.org/pandomic/with_events.svg?branch=master)

# WithEvents
A simple events system for Ruby apps which supports 
bi-directional SNS/SQS messaging.

## Dependencies
* Ruby >= 2.3.3
* Rake >= 12.3.1
* Activesupport >= 4.2.7
* Sidekiq >= 3.5.3
* Circuitry 3.2

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'with_events'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install with_events
```

## Configuration

### Setting up a Rakefile

If you are going to use included rake tasks, add this to your
Rakefile:

```ruby
spec = Gem::Specification.find_by_name 'with_events'
load "#{spec.gem_dir}/lib/tasks/with_events/with_events_tasks.rake"
```

### Setting up Circuitry

If you would like to use SNS/SQS subscribing/publishing features,
you need to configure Circuitry gem. Just follow [this instructions](https://github.com/kapost/circuitry#usage).

## Usage

### Basic Usage (in-app publish/subscribe)
This type of messaging does not require Rakefile or Circuitry configuration.

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

There might be situations where you will have a lot of events
which have pretty same configuration. To make life easier, you
can use `configure_all` method, which will aply configuration for
all events in the stream.

```ruby
require 'with_events'

class MyHeroClass
  include WithEvents
  
  stream :my_lovely_stream do
    configure_all callback: :call_me_if_game_over
    
    event :event_one,
          condition: -> { true }
          
    event :event_one,
          condition: -> { false }
  end
  
  def really_game_over?
    true
  end
  
  def call_me_if_game_over
    puts 'Game over'
  end
end

hero = MyHeroClass.new
hero.event_one!
#=> Game over
hero.event_two!
#=> Game over
```

### Using with daily/hourly rake triggers for batch processing

You may want to automate a bit the process of asking resources if
they are ready to trigger events (by calling `#*?`). This can
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
          appearance: :daily, # or :hourly
          batch: -> { User.active.find_each } # any Enumerable
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

**NOTE that this will also subscribe you to SQS/SNS events.**

### Sending events to SNS/SQS

You may send messages to SNS/SQS by setting a `topic` option for
the stream. In addition, you need to specify `identifier` option.

`identifier` option (symbol, Proc, Class) allows to identify incoming message and
bind an `id` for outgoing ones.

```ruby
require 'with_events'

class MyModel < ActiveRecord::Base
  include WithEvents
  
  stream :my_lovely_stream, topic: 'my-topic' do
    event :game_over,
          condition: :really_game_over?,
          callback: :call_me_if_game_over,
          identifier: :id, # symbol, Proc or Class
  end
  
  def really_game_over?
    true
  end
  
  def call_me_if_game_over
    puts 'Game over'
  end
end
```

### Subscribing to SNS/SQS events

To subscribe to SNS/SQS events you need to specify `topic` and
`finder` options.

The `finder` option represents invokable type which should return
resource identified by `identifier` invokable by the sender.

**NOTE that subscriber will take the process. Run it in a separate process**

```ruby
require 'with_events'

class MyClass
  include WithEvents
  
  stream :my_lovely_stream, topic: 'my-topic' do
    event :game_over,
          condition: :really_game_over?,
          callback: :call_me_if_game_over,
          finder: ->(message) { SomeModel.find(message.id) }
  end
  
  def really_game_over?
    true
  end
  
  def call_me_if_game_over
    puts 'Game over'
  end
end

WithEvents::Stream.subscribe # NOTE this line
```

### Supported invokable types
* Proc
* Symbol
* Class

You may use them for `condition`, `callback`, `identifier` or `finder` options.

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
