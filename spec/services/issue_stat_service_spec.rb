describe IssueStatService do
  let(:board) { create(:board, :with_columns) }
  describe '#create!' do
    subject { IssueStatService.create!(board, issue) }
    let(:issue) { OpenStruct.new(number: 1, created_at: Time.current, updated_at: Time.current) }
    let(:now) { Time.current }
    let(:first_column) { board.columns.first }
    before { allow(Time).to receive(:current).and_return(now) }

    it { is_expected.to be_persisted }
    it { expect(subject.number).to eq issue.number }
    it { expect(subject.created_at).to eq issue.created_at }
    it { expect(subject.updated_at).to eq issue.updated_at }
    it { expect(subject.closed_at).to eq issue.closed_at }
    it { expect(subject.track_data).to eq({ columns: { first_column.id => { in_at: now, out_at: nil } } }) }
  end
end
