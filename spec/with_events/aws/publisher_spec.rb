RSpec.describe WithEvents::Aws::Publisher do
  let(:event) do
    double(name: :test, identifier: -> { 1 }, stream: double(name: :test, topic: :test))
  end

  let(:resource) { double }

  subject { described_class.new(event, resource) }

  describe 'When calling #publish' do
    context 'And event has identifier' do
      it 'Then publishes message' do
        expect_any_instance_of(WithEvents::Aws::Topic).to receive(:publish)

        subject.publish
      end
    end

    context 'And event has no identifier' do
      let(:event) { double(identifier: nil) }

      it 'Then does not publish message' do
        expect_any_instance_of(WithEvents::Aws::Topic).not_to receive(:publish)

        subject.publish
      end
    end
  end
end
