describe Boards::Synchronizer do
  describe '.call' do
    subject { Boards::Synchronizer.call(user: user, board: board) }
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    let(:github_api) { double(issues: issues, issue: issue_1) }
    let(:archiver) { double(call: issue_stat_1) }
    let(:number) { 1 }
    before { allow(IssueStats::Archiver).to receive(:new).with(user, board, number).and_return(archiver) }
    before { user.github_api = github_api }

    context 'nothing to archive' do
      let!(:issue_stat_1) do
        create(:issue_stat, board: board, number: issue_1.number)
      end
      before { subject }

      context 'all issue visible' do
        let(:issues) { [issue_1] }
        let(:issue_1) { stub_issue(number: number) }

        it { expect(archiver).not_to have_received(:call) }
      end
    end

    context 'archive issue which not visible' do
      let(:issues) { [issue_2] }
      let(:issue_1) { stub_closed_issue(number: number) }
      let(:issue_2) { stub_issue(number: number + 1) }
      let!(:issue_stat_1) do
        create(:issue_stat, board: board, number: issue_1.number)
      end
      let!(:issue_stat_2) do
        create(:issue_stat, board: board, number: issue_2.number)
      end
      let!(:issue_stat_3) do
        create(:issue_stat, :archived, board: board, number: -1)
      end
      before { subject }

      it { expect(archiver).to have_received(:call) }
    end
  end
end
