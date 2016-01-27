describe Graphs::Forecasts::IntervalSplitter do
  let(:board) { build :board, created_at: created_at }
  let(:splitter) { Graphs::Forecasts::IntervalSplitter.new(board) }

  describe '#weeks' do
    subject { splitter.weeks }

    context 'current' do
      let(:created_at) { 0.second.ago }

      its(:count) { is_expected.to eq 1 }
      its(:first) do
        is_expected.to eq (created_at.beginning_of_week..created_at.end_of_week)
      end
    end

    context 'one week ago' do
      let(:created_at) { 1.week.ago }

      its(:count) { is_expected.to eq 2 }
      its(:first) do
        is_expected.to eq (created_at.beginning_of_week..created_at.end_of_week)
      end
    end

    context 'more than three weeks ago' do
      let(:created_at) { 3.weeks.ago - 1.day }

      its(:count) { is_expected.to eq 4 }
      its(:first) do
        is_expected.to eq (created_at.beginning_of_week..created_at.end_of_week)
      end
      its(:last) do
        is_expected.
          to eq (Time.current.beginning_of_week..Time.current.end_of_week)
      end
    end
  end
end
