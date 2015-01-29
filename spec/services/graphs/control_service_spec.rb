describe Graphs::ControlService do
  let(:service) { Graphs::ControlService.new(board) }
  let(:board) { create(:board, :with_columns) }

  describe '#issues_series_data' do
    subject { service.issues_series_data }
    context :empty do
      it { is_expected.to be_empty }
    end

    context :not_empty do
      let!(:open_issue) { create(:issue_stat, :open, board: board) }
      let!(:closed_issue) { create(:issue_stat, :closed, board: board) }
      it { is_expected.to have(1).item }
      it { expect(subject.first[:number]).to eq closed_issue.number }
    end
  end

  describe '#average_series_data' do
    subject { service.average_series_data }

    context :empty do
      it { is_expected.to be_empty }
    end

    context 'One issue' do
      let!(:closed_issue) { create(:issue_stat, :closed, board: board) }
      it { is_expected.to have(1).item }
    end

    context 'Several issues - in line onlty two points' do
      let!(:closed_issues) { create_list(:issue_stat, 3, :closed, board: board) }
      it { is_expected.to have(2).items }
    end

    context :order do
      let!(:issue_stat_1) { create(:issue_stat, :closed, number: 1, created_at: 10.days.ago, closed_at: 1.day.ago, board: board) }
      let!(:issue_stat_2) { create(:issue_stat, :closed, number: 2, created_at: 10.days.ago, closed_at: 3.day.ago, board: board) }
      let!(:issue_stat_3) { create(:issue_stat, :closed, number: 3, created_at: 10.days.ago, closed_at: 0.day.ago, board: board) }
      it { expect(subject.first[:x]).to eq issue_stat_2.closed_at.to_js }
      it { expect(subject.last[:x]).to eq issue_stat_3.closed_at.to_js }
    end
  end

  describe '#rolling_average_series_data' do
    subject { service.rolling_average_series_data }

    context :empty do
      it { is_expected.to be_empty }
    end

    context 'One issue' do
      let!(:closed_issue) { create(:issue_stat, :closed, board: board) }
      it { is_expected.to have(1).item }
    end

    context 'Issues less than rolling window' do
      let!(:issue_stats) { create_list(:issue_stat, Graphs::ControlService::ROLLING_WINDOW - 1, :closed, board: board) }
      it { is_expected.to have(1).item }
    end

    context 'Issues eq rolling window' do
      let!(:issue_stats) { create_list(:issue_stat, Graphs::ControlService::ROLLING_WINDOW, :closed, board: board) }
      it { is_expected.to have(1).item }
    end

    context 'Issues greate than rolling window' do
      let!(:issue_stats) { create_list(:issue_stat, Graphs::ControlService::ROLLING_WINDOW + 1, :closed, board: board) }
      it { is_expected.to have(2).item }
    end
  end
end
