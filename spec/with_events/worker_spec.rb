RSpec.describe WithEvents::Worker do
  let(:hourly_resource) { double(hello?: true, hello!: nil) }

  let(:hourly_event) do
    double(
      name: :hello,
      options: {
        background: true,
        appearance: :hourly,
        batch: -> { [hourly_resource] }
      }
    )
  end

  let(:hourly_resource_2) { double(hi?: false, hi!: nil) }

  let(:hourly_event_2) do
    double(
      name: :hi,
      options: {
        background: true,
        appearance: :hourly,
        batch: -> { [hourly_resource_2] }
      }
    )
  end

  let(:daily_resource) { double(hello2?: true, hello2!: nil) }

  let(:daily_event) do
    double(
      name: :hello2,
      hello2?: true,
      hello2!: nil,
      options: {
        background: true,
        appearance: :daily,
        batch: -> { [daily_resource] }
      }
    )
  end

  let(:regular_resource) { double(hello3?: true, hello3!: nil) }

  let(:regular_event) do
    double(
      name: :hello3,
      options: {}
    )
  end

  describe 'When calling #perform' do
    context 'And calling for hourly tasks' do
      context 'And there are hourly tasks registered' do
        it 'Then executes available hourly tasks only' do
          expect(hourly_resource).to receive(:hello!)

          expect(hourly_resource_2).not_to receive(:hi!)

          expect(daily_resource).not_to receive(:hello2!)

          expect(regular_resource).not_to receive(:hello3!)

          allow(WithEvents::Stream)
            .to receive(:find)
            .and_return(double(events: [hourly_event, hourly_event_2, daily_event, regular_event]))

          subject.perform(:fake_stream, :hello, :hourly)
        end
      end

      context 'And there are no hourly tasks registered' do
        it 'Then executes nothing' do
          expect(hourly_resource).not_to receive(:hello!)

          expect(hourly_resource_2).not_to receive(:hi!)

          expect(daily_resource).not_to receive(:hello2!)

          expect(regular_resource).not_to receive(:hello3!)

          allow(WithEvents::Stream)
            .to receive(:find)
            .and_return(double(events: [daily_event, hourly_event_2, regular_event]))

          subject.perform(:fake_stream, :hello, :hourly)
        end
      end
    end

    context 'And calling for daily tasks' do
      context 'And there are daily tasks registered' do
        it 'Then executes available daily tasks only' do
          expect(hourly_resource).not_to receive(:hello!)

          expect(hourly_resource_2).not_to receive(:hi!)

          expect(daily_resource).to receive(:hello2!)

          expect(regular_resource).not_to receive(:hello3!)

          allow(WithEvents::Stream)
            .to receive(:find)
            .and_return(double(events: [hourly_event, hourly_event_2, daily_event, regular_event]))

          subject.perform(:fake_stream, :hello2, :daily)
        end
      end

      context 'And there are no daily tasks registered' do
        it 'Then executes nothing' do
          expect(hourly_resource).not_to receive(:hello!)

          expect(hourly_resource_2).not_to receive(:hi!)

          expect(daily_resource).not_to receive(:hello2!)

          expect(regular_resource).not_to receive(:hello3!)

          allow(WithEvents::Stream)
            .to receive(:find)
            .and_return(double(events: [hourly_event, hourly_event_2, regular_event]))

          subject.perform(:fake_stream, :hello2, :daily)
        end
      end
    end
  end
end
