describe GuestBoardIssue do
  let(:board_issue) { GuestBoardIssue.new(issue, nil, nil) }
  let(:issue) { nil }

  describe '#comments' do
    subject { board_issue.comments }
    it { is_expected.to be_zero }
  end
end
