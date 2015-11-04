describe IssueStats::LazySyncChecklist do
  let(:user) { build :user }
  let(:number) { 1 }
  let(:board) { build(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(user, board) }
  let(:api) { double(issue_comments: comments) }
  let(:comments) { [] }
  let!(:issue_stat) do
    create(
      :issue_stat,
      number: number,
      board: board,
      checklist: 2,
      checklist_progress: 1
    )
  end
  before { allow(user).to receive(:github_api).and_return(api) }
  before { allow(IssueStats::SyncChecklist).to receive(:call) }

  describe '.call' do
    context 'without fresh comments' do
      before do
        IssueStats::LazySyncChecklist.call(
          user: user,
          board_bag: board_bag,
          number: number,
        )
      end

      it do
        expect(IssueStats::SyncChecklist).
          to have_received(:call).
          with(issue_stat: issue_stat, comments: comments)
      end
      it { expect(api).to have_received(:issue_comments) }
    end

    context 'with fresh comments' do
      let(:fresh_comments) { [OpenStruct.new] }
      before do
        IssueStats::LazySyncChecklist.call(
          user: user,
          board_bag: board_bag,
          number: number,
          comments: fresh_comments
        )
      end

      it do
        expect(IssueStats::SyncChecklist).
          to have_received(:call).
          with(issue_stat: issue_stat, comments: fresh_comments)
      end
      it { expect(api).not_to have_received(:issue_comments) }
    end
  end
end
