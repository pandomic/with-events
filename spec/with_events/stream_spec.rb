RSpec.describe WithEvents::Stream do
  let(:klass) { Class.new }

  subject { described_class.new(:hello, klass) }

  describe 'When initialized' do
    it 'Then keeps track of streams' do
      expect { subject }.to change(described_class.streams, :size).by(1)
    end
  end

  describe 'When calling #event' do
    it 'Then registers event' do
      subject.event(:name, {})

      expect(subject.events.size).to eq(1)
    end
  end

  describe 'When calling #configure_all' do
    let(:stream) { double }

    it 'Then sets default configuration for all events' do
      subject.configure_all(identifier: :id)

      expect(WithEvents::Event).to receive(:new)
                   .with(:test, klass, { identifier: :id, stream: subject })

      subject.event(:test)
    end
  end

  describe 'When calling #reset_configure_all' do
    let(:stream) { double }

    it 'Then resets default configuration for all events' do
      subject.configure_all(identifier: :id)

      expect(WithEvents::Event)
        .to receive(:new)
        .with(:test, klass, { identifier: :id, stream: subject })

      subject.event(:test)

      subject.reset_configure_all

      expect(WithEvents::Event)
        .to receive(:new)
        .with(:test, klass, { stream: subject })

      subject.event(:test)
    end
  end

  describe 'When calling #notify' do
    let(:stream) { double }

    context 'And SNS topic is set' do
      subject { described_class.new(:hello, klass, topic: :hello) }

      it 'Then notifies SNS topic' do
        expect_any_instance_of(WithEvents::Aws::Publisher).to receive(:publish)

        subject.notify(double(name: :test), double)
      end
    end

    context 'And watchers are set' do
      let(:resource) { double }

      it 'Then notifies watchers' do
        expect(resource).to receive(:instance_exec)

        subject.on(:test) { }

        subject.notify(double(name: :test), resource)
      end
    end

    context 'And neither watchers nor topic is set' do
      let(:resource) { double }
      subject { described_class.new(:hello, klass) }

      it 'Then does not notifies SNS/watchers' do
        expect(resource).not_to receive(:instance_exec)

        subject.notify(double(name: :test), resource)
      end
    end
  end

  describe 'When calling #notify_watchers' do
    let(:stream) { double }

    context 'And watchers are set' do
      let(:resource) { double }

      it 'Then notifies watchers' do
        expect(resource).to receive(:instance_exec)

        subject.on(:test) { }

        subject.notify(double(name: :test), resource)
      end
    end

    context 'And watchers are not set' do
      let(:resource) { double }
      subject { described_class.new(:hello, klass) }

      it 'Then does not notifies watchers' do
        expect(resource).not_to receive(:instance_exec)

        subject.notify(double(name: :test), resource)
      end
    end
  end

  describe 'When calling #on' do
    it 'Then registers watcher' do
      subject.on(:name) {}

      expect(subject.watchers[:name].size).to eq(1)
    end
  end

  describe 'When calling #notify' do
    let(:watcher) { -> {} }
    let(:resource) { double }

    before do
      subject.on(:name, &watcher)
    end

    it 'Then notifies watchers' do
      expect(resource).to receive(:instance_exec)

      subject.notify(double(name: :name), resource)
    end

    it 'Then does not notify watchers' do
      expect(resource).not_to receive(:instance_exec)

      subject.notify(double(name: :hero), resource)
    end

    context 'And topic is set' do
      subject { described_class.new(:hello, Class.new, topic: :test_topic) }

      it 'Then notifies topic' do
        expect_any_instance_of(WithEvents::Aws::Publisher).to receive(:publish)

        subject.notify(double(name: :hero), resource)
      end
    end
  end

  describe 'When calling .streams' do
    it 'Then returns number of registered streams' do
      expect do
        subject
        described_class.new(:hello_hero, Class.new)
      end.to change(described_class.streams, :size).by(2)
    end
  end

  describe 'When calling .find_or_initialize' do
    context 'And stream already exists' do
      it 'Then returns existing stream' do
        subject

        expect(described_class).not_to receive(:new)

        described_class.find_or_initialize(:hello, Class.new)
      end
    end

    context 'And stream does not exists' do
      it 'Then creates a new stream' do
        subject

        expect(described_class).to receive(:new)

        described_class.find_or_initialize(:hey_stream, Class.new)
      end
    end
  end

  describe 'When calling .subscribe' do
    subject { described_class.new(:hello, klass, topic: :test, subscribe: true) }

    context 'And there is no active subscription' do
      context 'And stream has topic and may be subscribed' do
        it 'Then subscribes to SQS queue' do
          expect_any_instance_of(WithEvents::Aws::Topic).to receive(:subscribe)

          subject.class.subscribe
        end
      end
    end

    context 'And there is already active subscription' do
      context 'And stream has topic and may be subscribed' do
        before do
          described_class.new(:hello_2, klass, topic: :test, subscribe: true)
        end

        it 'Then does not subscribe to SQS queue' do
          expect_any_instance_of(WithEvents::Aws::Topic).not_to receive(:subscribe)

          subject.class.subscribe
        end
      end

      context 'And stream has no topic and can not be subscribed' do
        subject { described_class.new(:hello, klass) }

        it 'Then does not subscribe to SQS queue' do
          expect_any_instance_of(WithEvents::Aws::Topic).not_to receive(:subscribe)

          subject.class.subscribe
        end
      end
    end
  end

  describe 'When calling .find' do
    context 'And stream already exists' do
      it 'Then returns existing stream' do
        subject

        expect(described_class).not_to receive(:new)

        described_class.find_or_initialize(:hello, Class.new)
      end
    end
  end
end
