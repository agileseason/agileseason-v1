describe IssueStats::LifetimeStarter do
  let(:starter) { IssueStats::LifetimeStarter.new(issue_stat, column) }

  describe '#call' do
    subject { starter.call }
    let(:issue_stat) { create(:issue_stat, column: column) }
    let(:column) { board.columns.first }
    let(:board) { create(:board, :with_columns) }

    it { is_expected.to be_persisted }
    its(:column) { is_expected.to eq column }
    its(:in_at) { is_expected.not_to be_nil }
    its(:out_at) { is_expected.to be_nil }
  end
end
