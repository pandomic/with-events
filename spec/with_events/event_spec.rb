RSpec.describe WithEvents::Event do
  let(:dummy_class) do
    Class.new
  end

  describe 'When initializing' do
    it 'Then defines #*? and #*! methods on the klass' do
      described_class.new(:hello_world, dummy_class)

      expect(dummy_class.instance_methods).to include(:hello_world?)
      expect(dummy_class.instance_methods).to include(:hello_world!)
    end
  end

  describe 'When calling #*? method' do
    before do
      described_class.new(:hello_world, dummy_class)
    end

    it 'Executes Invoker' do
      expect_any_instance_of(WithEvents::Invoker).to receive(:invoke)

      dummy_class.new.hello_world?
    end
  end

  describe 'When calling #*! method' do
    let(:stream) { double(notify: nil) }

    before do
      described_class.new(:hello_world, dummy_class, stream: stream)
    end

    it 'Executes Invoker' do
      expect_any_instance_of(WithEvents::Invoker).to receive(:invoke)

      dummy_class.new.hello_world!
    end

    it 'Notifies Stream' do
      allow_any_instance_of(WithEvents::Invoker).to receive(:invoke)

      expect(stream).to receive(:notify)

      dummy_class.new.hello_world!
    end
  end
end
