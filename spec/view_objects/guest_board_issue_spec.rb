describe GuestBoardIssue do
  let(:board_issue) { GuestBoardIssue.new(nil, nil, nil) }

  describe '#comments' do
    subject { board_issue.comments }
    it { is_expected.to be_zero }
  end

  describe '#column_id' do
    subject { board_issue.column_id }
    it { is_expected.to be_zero }
  end

  describe '#due_date_at' do
    subject { board_issue.due_date_at }
    it { is_expected.to be_nil }
  end
end
