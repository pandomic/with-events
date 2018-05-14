RSpec.describe WithEvents::Aws::Message do
  subject { described_class.new(event: :test, stream: :test_stream, identifier: 1) }

  describe 'When calling attr readers' do
    it 'Then returns attrs' do
      expect(subject.event).to eq(:test)

      expect(subject.stream).to eq(:test_stream)

      expect(subject.identifier).to eq(1)
    end
  end

  describe 'When calling #serialize' do
    it 'Then returns message hash' do
      expect(subject.serialize)
        .to eq('event' => :test, 'stream' => :test_stream, 'identifier' => 1)
    end
  end

  describe 'When calling .from_sqs' do
    it 'Then returns a new message' do
      message = subject.class.from_sqs('event' => :test,
                                       'stream' => :test_stream,
                                       'identifier' => 1)

      expect(message.event).to eq(:test)

      expect(message.stream).to eq(:test_stream)

      expect(message.identifier).to eq(1)
    end
  end
end
