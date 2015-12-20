describe BoardIssue do
  let(:board_issue) { BoardIssue.new(issue, issue_stat) }
  let(:issue) {}
  let(:issue_stat) {}

  describe '#number' do
    subject { board_issue.number }
    let(:issue) { stub_issue }
    it { is_expected.to eq issue.number }
  end

  describe '#state' do
    subject { board_issue.state }
    let(:issue) { stub_issue(state: 'open') }
    it { is_expected.to eq 'open' }
  end

  describe '#archive?' do
    subject { board_issue.archive? }

    context 'true' do
      let(:issue_stat) { build(:issue_stat, archived_at: Time.current) }
      it { is_expected.to eq true }
    end

    context 'false' do
      let(:issue_stat) { build(:issue_stat, archived_at: nil) }
      it { is_expected.to eq false }
    end

    context 'false if no issue_stat' do
      let(:issue_stat) { nil }
      it { is_expected.to eq false }
    end
  end

  describe '#open?' do
    subject { board_issue.open? }
    let(:issue) { stub_issue(state: state) }

    context :true do
      let(:state) { 'open' }
      it { is_expected.to eq true }
    end

    context :false do
      let(:state) { 'closed' }
      it { is_expected.to eq false }
    end
  end

  describe '#closed?' do
    subject { board_issue.closed? }
    let(:issue) { stub_issue(state: state) }

    context :true do
      let(:state) { 'closed' }
      it { is_expected.to eq true }
    end

    context :false do
      let(:state) { 'open' }
      it { is_expected.to eq false }
    end
  end

  describe '#visible?' do
    subject { board_issue.visible? }

    context :true do
      let(:issue_stat) { build(:issue_stat, archived_at: nil) }
      it { is_expected.to eq true }
    end

    context :false do
      context 'issue stat is nil' do
        let(:issue_stat) {}
        it { is_expected.to eq false }
      end

      context 'issue is archived' do
        let(:issue_stat) { build(:issue_stat, archived_at: Time.current) }
        it { is_expected.to eq false }
      end
    end
  end

  describe 'full_state' do
    subject { board_issue.full_state }
    let(:issue_stat) { build(:issue_stat) }

    context 'open' do
      let(:issue) { stub_issue }
      it { is_expected.to eq 'open' }
    end

    context 'closed' do
      let(:issue) { stub_closed_issue }
      it { is_expected.to eq 'closed' }
    end

    context 'archived' do
      let(:issue_stat) { build(:issue_stat, :archived) }
      it { is_expected.to eq 'archived' }
    end
  end

  describe '#no_comments_available?' do
    subject { board_issue.no_comments_available? }
    let(:issue) { stub_issue(comments: 1) }

    context 'true' do
      before { allow(board_issue).to receive(:comments).and_return 0 }
      it { is_expected.to eq true }
    end

    context 'false' do
      it { is_expected.to eq false }
    end
  end

  describe '#due_date_at' do
    subject { board_issue.due_date_at }

    context 'issue_stat is nil' do
      it { is_expected.to be_nil }
    end

    context 'issue_stat is not nil' do
      let(:issue_stat) { build(:issue_stat, due_date_at: Time.current) }
      it { is_expected.to eq issue_stat.due_date_at }
    end
  end

  describe '#column' do
    subject { board_issue.column }

    context 'issue_stat is nil' do
      it { is_expected.to be_nil }
    end

    context 'issue_stat is not nil' do
      let(:issue_stat) { build(:issue_stat, column: column) }
      let(:column) { build(:column) }
      it { is_expected.to eq column }
    end
  end

  describe '#column_id' do
    subject { board_issue.column_id }

    context 'issue_stat is nil' do
      it { is_expected.to be_nil }
    end

    context 'issue_stat is not nil' do
      let(:issue_stat) { build(:issue_stat, column: column) }
      let(:column) { build_stubbed(:column) }
      it { is_expected.to eq column.id }
    end
  end
end
