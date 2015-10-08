describe IssueStats::SyncChecklist do
  let(:user) { create :user }
  let(:number) { 1 }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(user, board) }
  let(:api) { double(issue_comments: comments) }
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

  describe '.call' do
    subject do
      IssueStats::SyncChecklist.call(
        user: user,
        board_bag: board_bag,
        number: number
      )
    end

    context 'no comment' do
      let(:comments) { [] }

      its(:checklist) { is_expected.to be_nil }
      its(:checklist_progress) { is_expected.to be_nil }
    end

    context 'with comment without checkboxes' do
      let(:comments) { [comment_1, comment_2] }
      let(:comment_1) { double(body: 'test comment 1') }
      let(:comment_2) { double(body: 'test comment 2') }

      its(:checklist) { is_expected.to be_nil }
      its(:checklist_progress) { is_expected.to be_nil }
    end

    context 'with comment with checkboxes' do
      let(:comments) { [comment_1, comment_2] }
      let(:comment_1) { double(body: 'test comment 1') }
      let(:comment_2) { double(body: body) }
      let(:body) do
<<MARKDOWN
Checkbox header

- [ ] ch1
- [x] ch2
- [x] ch3
- [ ] ch4
- [ ] ch5

footer
MARKDOWN
      end

      its(:checklist) { is_expected.to eq 5 }
      its(:checklist_progress) { is_expected.to eq 2 }
    end
  end

  describe '.call with fresh comments' do
    subject do
      IssueStats::SyncChecklist.call(
        user: user,
        board_bag: board_bag,
        number: number,
        comments: comments
      )
    end

    context 'with comment without checkboxes' do
      let(:comments) { [comment_1] }
      let(:comment_1) { double(body: 'test comment 1') }

      its(:checklist) { is_expected.to be_nil }
      its(:checklist_progress) { is_expected.to be_nil }

      context 'behavior' do
        before { subject }
        it { expect(api).not_to have_received(:issue_comments) }
      end
    end
  end
end
