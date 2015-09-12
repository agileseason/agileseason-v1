describe IssueStats::Archiver do
  let(:archiver) { IssueStats::Archiver.new(user, board_bag, issue.number) }
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }
  let(:github_api) { double(issue: issue) }
  before { allow(user).to receive(:github_api).and_return(github_api) }

  describe '#call' do
    subject { archiver.call }

    context 'issue not closed yet' do
      let(:issue) { stub_issue }
      let!(:issue_stat) { create(:issue_stat, board: board, number: issue.number) }

      context 'behavior' do
        after { subject }

        it { expect(Activities::ArchiveActivity).not_to receive(:create_for) }
        it { expect_any_instance_of(Lifetimes::Finisher).not_to receive(:call) }
      end

      context 'result' do
        before { subject }

        it { is_expected.to be_nil }
        it { expect(issue_stat.reload).not_to be_archived }
      end
    end

    context 'closed issue' do
      let(:issue) { stub_closed_issue }
      let!(:issue_stat) { create(:issue_stat, :closed, board: board, number: issue.number) }

      context 'behavior' do
        after { subject }
        it { expect(Activities::ArchiveActivity).to receive(:create_for) }
        it { expect_any_instance_of(Lifetimes::Finisher).to receive(:call) }
      end

      context 'result' do
        before { subject }

        it { is_expected.not_to be_nil }
        it { expect(issue_stat.reload).to be_archived }
      end
    end
  end
end
