describe IssueStats::Sorter do
  let(:sorter) { IssueStats::Sorter.new(column_to, number, is_force_sort) }

  describe '#call' do
    subject { sorter.call }
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
