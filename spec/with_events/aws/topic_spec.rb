RSpec.describe WithEvents::Aws::Topic do
  subject { described_class.new(:test) }

  describe 'When calling #publish' do
    it 'Then calls Circuitry to publish a message' do
      expect(Circuitry).to receive(:publish)

      subject.publish(double(serialize: {}))
    end
  end

  describe 'When calling #subscribe' do
    it 'Then calls Circuitry to subscribe to a queue' do
      expect(Circuitry).to receive(:subscribe)

      subject.subscribe {}
    end
  end
end
