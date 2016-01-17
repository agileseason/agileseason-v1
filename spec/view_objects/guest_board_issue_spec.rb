describe GuestBoardIssue do
  let(:board_issue) { GuestBoardIssue.new(user, board, issue, issue_stat) }
  let(:user) {}
  let(:board) {}
  let(:issue) {}
  let(:issue_stat) {}

  describe '#comments' do
    subject { board_issue.comments }
    it { is_expected.to be_zero }
  end

  describe '#due_date_at_to_js' do
    subject { board_issue.due_date_at_to_js }

    context 'without issue_stat' do
      let(:issue_stat) {}
      it { is_expected.to be_nil }
    end

    context 'with issue_stat' do
      let(:issue_stat) { build(:issue_stat, due_date_at: Time.current) }
      it { is_expected.to eq issue_stat.due_date_at.to_i * 1000 }
    end
  end

  describe '#ready?' do
    subject { board_issue.ready? }

    context 'without issue_stat' do
      let(:issue_stat) {}
      it { is_expected.to be_nil }
    end

    context 'with issue_stat' do
      context 'true' do
        let(:issue_stat) { build(:issue_stat, is_ready: true) }
        it { is_expected.to eq true }
      end

      context 'false' do
        let(:issue_stat) { build(:issue_stat, is_ready: false) }
        it { is_expected.to eq false }
      end
    end
  end
end
