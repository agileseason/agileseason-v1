describe IssueStatService do
  let(:user) { build(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:service) { IssueStatService }

  describe '.create' do
    subject { service.create(board, issue) }
    let(:issue) { stub_issue }

    it { is_expected.to be_persisted }
    its(:number) { is_expected.to eq issue.number }
    its(:column) { is_expected.to eq board.default_column }
    its(:created_at) { is_expected.to eq issue.created_at }
    its(:updated_at) { is_expected.to eq issue.updated_at }
    its(:closed_at) { is_expected.to eq issue.closed_at }
  end

  describe '.find_or_build_issue_stat' do
    subject { service.find_or_build_issue_stat(board, issue) }
    let(:issue) { stub_issue }

    it { is_expected.not_to be_nil }
    it { is_expected.not_to be_persisted }
    its(:board_id) { is_expected.to eq board.id }
    its(:number) { is_expected.to eq issue.number }
  end
end
