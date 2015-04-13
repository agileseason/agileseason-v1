describe FrequencyService do
  let(:board) { create(:board, :with_columns) }
  let(:service) { FrequencyService.new(board) }
  let(:zero_point) { [0, 0] }

  describe '.fetch_group' do
    subject { service.fetch_group }

    context 'empty but have zero point' do
      it { is_expected.to eq [zero_point] }
    end

    context 'only open issues - only zero point again' do
      let!(:issue) { create(:issue_stat, :open, board: board) }
      it { is_expected.to eq [zero_point] }
    end

    context 'one closed issue plus zero point' do
      let!(:issue) { create(:issue_stat, :closed, created_at: 1.day.ago, board: board) }
      let(:expected_duration) { (issue.closed_at - issue.created_at).to_i / 86400 + 1 }
      it { is_expected.to have(2).item }
      it { expect(subject.last.first).to eq expected_duration }
      it { expect(subject.last.second).to eq 1 }
    end

    context 'sort by duration (2 points + 1 zero)' do
      let!(:issue_1) { create(:issue_stat, :closed, wip: 2, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, wip: 1, board: board) }
      let(:expected_duration_1) { (issue_1.closed_at - issue_1.created_at).to_i / 86400 + 1 }
      let(:expected_duration_2) { (issue_2.closed_at - issue_2.created_at).to_i / 86400 + 1 }
      it { is_expected.to have(3).item }
      it { expect(subject.second.first).to eq expected_duration_2 }
      it { expect(subject.third.first).to eq expected_duration_1 }
    end
  end

  describe '.average_forecast_elapsed_days' do
    subject { service.average_forecast_elapsed_days }

    context 'no issues' do
      it { is_expected.to be_nil }
    end

    context 'no history no forecast' do
      let(:issue) { create(:issue_stat, :open) }
      it { is_expected.to be_nil }
    end

    context 'one closed issue for 1 day, then forecast 1 day by issue' do
      let!(:issue_1) { create(:issue_stat, :closed, wip: 1, board: board) }

      context 'no open issue' do
        it { is_expected.to eq 0 }
      end

      context 'one open issue' do
        let!(:issue_2) { create(:issue_stat, :open, board: board) }
        it { is_expected.to eq 1 }
      end

      context 'two open issue' do
        let!(:open_issues) { create_list(:issue_stat, 2, :open, board: board) }
        it { is_expected.to eq 2 }
      end
    end

    context 'closed [1, 1, 2, 4], open 2 then forecast 2 days by issue' do
      let!(:issue_1) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_3) { create(:issue_stat, :closed, wip: 2, board: board) }
      let!(:issue_4) { create(:issue_stat, :closed, wip: 4, board: board) }
      let!(:issue_open) { create(:issue_stat, :open, board: board) }
      it { is_expected.to eq 2 }
    end

    context 'Rounding - closed [1, 2], open 2 then forecast 1.5' do
      let!(:issue_1) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, wip: 2, board: board) }
      let!(:issue_open) { create(:issue_stat, :open, board: board) }
      it { is_expected.to eq 1.5 }
    end

    context 'Many small issues' do
      let!(:issue_1) { create(:issue_stat, :closed, created_at: 1.hour.ago, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, created_at: 2.hours.ago, board: board) }
      let!(:issue_3) { create(:issue_stat, :closed, created_at: 3.hours.ago, board: board) }
      let!(:issue_open) { create(:issue_stat, :open, board: board) }
      it { is_expected.to eq 0.08 }
    end
  end

  describe '.average_elapsed_days' do
    subject { service.average_elapsed_days }

    context 'no closed issues' do
      let!(:issue_open) { create(:issue_stat, :open, board: board) }
      it { is_expected.to be_nil }
    end

    context 'Rounding - closed [1, 2], open 2 then elapsed 1.50' do
      let!(:issue_1) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, wip: 2, board: board) }
      let!(:issue_open) { create(:issue_stat, :open, board: board) }
      it { is_expected.to eq 1.5 }
    end
  end
end
