describe IssueStats::Sorter do

  describe '#call' do
    subject do
      IssueStats::Sorter.call(
        column_to: column_to,
        number: number,
        is_force_sort: is_force_sort
      )
    end
    let(:column_to) { create(:column, issues: [], board: board) }
    let(:board) { create(:board, :with_columns) }
    let(:number) { 1 }

    context 'is force' do
      let(:is_force_sort) { true }

      it { is_expected.to eq true }

      context 'column.issues' do
        before { subject }
        it { expect(column_to.issues).to eq [number.to_s] }
      end
    end

    context 'is not force' do
      let(:is_force_sort) { false }
      it { is_expected.to be_nil }

      context 'column.issues' do
        before { subject }
        it { expect(column_to.issues).to eq [] }
      end
    end
  end
end
