RSpec.describe WithEvents::Trigger do
  let(:hourly_event) { double(name: :hello, may_hello?: true, hello!: nil, options: { background: true, appearance: :hourly }) }
  let(:hourly_event_2) { double(name: :hi, may_hi?: false, hi!: nil, options: { background: true, appearance: :hourly }) }
  let(:daily_event) { double(name: :hello2, may_hello2?: true, hello2!: nil, options: { background: true, appearance: :daily }) }
  let(:regular_event) { double(name: :hello3, may_hello3?: true, hello3!: nil, options: {}) }

  describe 'When calling #perform' do
    context 'And calling for hourly tasks' do
      context 'And there are hourly tasks registered' do
        it 'Then executes available hourly tasks only' do
          expect(hourly_event).to receive(:hello!)

          expect(hourly_event_2).not_to receive(:hi!)

          expect(daily_event).not_to receive(:hello2!)

          expect(regular_event).not_to receive(:hello3!)

          allow(WithEvents::Stream)
            .to receive(:streams)
            .and_return([double(events: [hourly_event, hourly_event_2, daily_event, regular_event])])

          subject.perform(:hourly)
        end
      end

      context 'And there are no hourly tasks registered' do
        it 'Then executes nothing' do
          expect(hourly_event).not_to receive(:hello!)

          expect(hourly_event_2).not_to receive(:hi!)

          expect(daily_event).not_to receive(:hello2!)

          expect(regular_event).not_to receive(:hello3!)

          allow(WithEvents::Stream)
            .to receive(:streams)
            .and_return([double(events: [daily_event, hourly_event_2, regular_event])])

          subject.perform(:hourly)
        end
      end
    end

    context 'And calling for daily tasks' do
      context 'And there are daily tasks registered' do
        it 'Then executes available daily tasks only' do
          expect(hourly_event).not_to receive(:hello!)

          expect(hourly_event_2).not_to receive(:hi!)

          expect(daily_event).to receive(:hello2!)

          expect(regular_event).not_to receive(:hello3!)

          allow(WithEvents::Stream)
            .to receive(:streams)
            .and_return([double(events: [hourly_event, hourly_event_2, daily_event, regular_event])])

          subject.perform(:daily)
        end
      end

      context 'And there are no daily tasks registered' do
        it 'Then executes nothing' do
          expect(hourly_event).not_to receive(:hello!)

          expect(hourly_event_2).not_to receive(:hi!)

          expect(daily_event).not_to receive(:hello2!)

          expect(regular_event).not_to receive(:hello3!)

          allow(WithEvents::Stream)
            .to receive(:streams)
            .and_return([double(events: [hourly_event, hourly_event_2, regular_event])])

          subject.perform(:daily)
        end
      end
    end
  end
end
