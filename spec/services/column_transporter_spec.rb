describe ColumnTransporter do
  let(:service) { ColumnTransporter.new(column) }
  let(:board) { create(:board, :with_columns, number_of_columns: 3) }

  describe '#can_move?' do
    subject { service.can_move? }

    context 'column without issues' do
      let(:column) { board.columns.first }
      it { is_expected.to eq true }
    end

    context 'column with not archived issues' do
      let(:column) { board.columns.first }
      let!(:issue_stats) { create(:issue_stat, column: column) }
      it { is_expected.to eq false }
    end

    context 'column with archived issues only' do
      let(:column) { board.columns.first }
      let!(:issue_stats) { create(:issue_stat, :archived, column: column) }
      it { is_expected.to eq true }
    end
  end

  describe '#move_left' do
    subject { service.move_left }
    before { subject }

    context 'first column not move' do
      let(:column) { board.columns.first }
      it { expect(column.order).to eq 1 }
    end

    context 'second column to be a first' do
      let(:column) { board.columns.second }
      let(:column_sorted_to) { board.columns.first }
      it { expect(column.reload.order).to eq 1 }
      it { expect(column_sorted_to.reload.order).to eq 2 }
    end
  end

  describe '#move_right' do
    subject { service.move_right }
    before { subject }

    context 'last column not move' do
      let(:column) { board.columns.last }
      it { expect(column.order).to eq 3 }
    end

    context 'second column to be a lat' do
      let(:column) { board.columns.second }
      let(:column_sorted_to) { board.columns.last }
      it { expect(column.reload.order).to eq 3 }
      it { expect(column_sorted_to.reload.order).to eq 2 }
    end
  end
end
