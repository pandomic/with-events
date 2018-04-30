RSpec.describe WithEvents::Stream do
  subject { described_class.new(:hello, Class.new) }

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
      expect(resource).to receive(:instance_exec).with(watcher)

      subject.notify(:name, resource)
    end

    it 'Then does not notify watchers' do
      expect(resource).not_to receive(:instance_exec)

      subject.notify(:hero, resource)
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
