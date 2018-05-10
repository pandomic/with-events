RSpec.describe WithEvents::Worker do
  let(:hourly_resource) { double(hello?: true, hello!: nil) }

  let(:hourly_event) do
    double(
      name: :hello,
      stream: double(batch: -> {}),
      options: {
        background: true,
        appearance: :hourly,
      }
    )
  end

  let(:hourly_resource_2) { double(hello?: false, hello!: nil) }

  let(:hourly_event_2) do
    double(
      name: :hi,
      stream: double(batch: -> {}),
      options: {
        background: true,
        appearance: :hourly,
      }
    )
  end

  let(:daily_resource) { double(hello2?: true, hello2!: nil) }

  let(:daily_event) do
    double(
      name: :hello2,
      stream: double(batch: -> {}),
      hello2?: true,
      hello2!: nil,
      options: {
        background: true,
        appearance: :daily,
      }
    )
  end

  let(:regular_resource) { double(hello2?: true, hello2!: nil) }

  let(:regular_event) do
    double(
      name: :hello3,
      stream: double(batch: -> {}),
      options: {}
    )
  end

  describe 'When calling #perform' do
    context 'And calling for hourly tasks' do
      context 'And there are hourly tasks registered' do
        it 'Then executes available hourly tasks only' do
          expect(hourly_resource).to receive(:hello!)

          expect(hourly_resource_2).not_to receive(:hello!)

          expect(daily_resource).not_to receive(:hello2!)

          expect(regular_resource).not_to receive(:hello2!)

          allow(WithEvents::Stream)
            .to receive(:find)
            .and_return(double(batch: -> { [hourly_resource] },
                               events: [hourly_event, hourly_event_2,
                                        daily_event, regular_event]))

          subject.perform(:fake_stream, :hello, :hourly)
        end
      end

      context 'And there are no hourly tasks registered' do
        it 'Then executes nothing' do
          expect(hourly_resource).not_to receive(:hello!)

          expect(hourly_resource_2).not_to receive(:hello!)

          expect(daily_resource).not_to receive(:hello2!)

          expect(regular_resource).not_to receive(:hello2!)

          allow(WithEvents::Stream)
            .to receive(:find)
            .and_return(double(batch: -> { [hourly_resource] },
                               events: [daily_event,
                                        hourly_event_2, regular_event]))

          subject.perform(:fake_stream, :hello, :hourly)
        end
      end
    end

    context 'And calling for daily tasks' do
      context 'And there are daily tasks registered' do
        it 'Then executes available daily tasks only' do
          expect(hourly_resource).not_to receive(:hello!)

          expect(hourly_resource_2).not_to receive(:hello!)

          expect(daily_resource).to receive(:hello2!)

          expect(regular_resource).not_to receive(:hello2!)

          allow(WithEvents::Stream)
            .to receive(:find)
            .and_return(double(batch: -> { [daily_resource] },
                               events: [hourly_event, hourly_event_2,
                                        daily_event, regular_event]))
          subject.perform(:fake_stream, :hello2, :daily)
        end
      end

      context 'And there are no daily tasks registered' do
        it 'Then executes nothing' do
          expect(hourly_resource).not_to receive(:hello!)

          expect(hourly_resource_2).not_to receive(:hello!)

          expect(daily_resource).not_to receive(:hello2!)

          expect(regular_resource).not_to receive(:hello2!)

          allow(WithEvents::Stream)
            .to receive(:find)
            .and_return(double(batch: -> { [daily_resource] },
                               events: [hourly_event, hourly_event_2,
                                        regular_event]))
          subject.perform(:fake_stream, :hello2, :daily)
        end
      end
    end
  end
end
