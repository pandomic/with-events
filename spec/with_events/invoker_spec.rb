RSpec.describe WithEvents::Invoker do
  describe 'When calling #invoke' do
    subject { described_class.new(callable) }

    context 'And calling for Proc' do
      let(:callable) { ->(*_args){} }

      it 'Then executes Proc in context and passes necessary arguments' do
        context = double

        expect(context).to receive(:instance_exec).with(1, 2, 3, &callable)

        subject.invoke(context, 1, 2, 3)
      end
    end

    context 'And calling for Symbol' do
      let(:callable) { :hello }

      it 'Then executes context method if method exists' do
        context = double

        expect(context).to receive(:hello).with(1, 2, 3)

        subject.invoke(context, 1, 2, 3)
      end
    end

    context 'And calling for Class' do
      let(:resource) { double }
      let(:callback) { double(call: nil) }
      let(:callable) { double(new: callback, instance_methods: [:call]) }

      it 'Then executes context class if #call method exists' do
        allow(callable).to receive(:is_a?) { |type| type == Class }

        expect(callback).to receive(:call).with(resource, 1, 2, 3)

        subject.invoke(resource, 1, 2, 3)
      end
    end

    context 'And calling for Undefined' do
      let(:callable) { double }

      it 'Then raises exception' do
        expect { subject.invoke(nil, 1, 2, 3) }
          .to raise_error(NotImplementedError)
      end
    end
  end
end
