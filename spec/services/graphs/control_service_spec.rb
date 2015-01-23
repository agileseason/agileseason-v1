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
  end
end
