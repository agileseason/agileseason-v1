describe BoardIssue do
  let(:board_issue) { BoardIssue.new(issue, issue_stat) }
  let(:issue) {}
  let(:issue_stat) {}

  describe '#number' do
    subject { board_issue.number }
    let(:issue) { OpenStruct.new(number: 1) }
    it { is_expected.to eq 1 }
  end

  describe '#state' do
    subject { board_issue.state }
    let(:issue) { OpenStruct.new(state: 'open') }
    it { is_expected.to eq 'open' }
  end

  describe '#archive?' do
    subject { board_issue.archive? }

    context :true do
      let(:issue_stat) { build(:issue_stat, archived_at: Time.current) }
      it { is_expected.to eq true }
    end

    context :false do
      let(:issue_stat) { build(:issue_stat, archived_at: nil) }
      it { is_expected.to eq false }
    end
  end
end
