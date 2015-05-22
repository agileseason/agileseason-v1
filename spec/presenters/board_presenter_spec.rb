describe BoardPresenter do
  let(:presenter) { present(:board, board) }

  describe '#name' do
    subject { presenter.name }

    context 'unknown type' do
      let(:board) { build(:board, name: 'test', type: nil) }
      it { is_expected.to eq "#{board.name}" }
    end

    context 'name with whitespace' do
      let(:board) { build(:kanban_board, name: 'test test') }
      it { is_expected.to eq 'test&nbsp;test' }
    end
  end

  describe '#last_column?' do
    subject { presenter.last_column?(column) }
    let(:board) { build(:board, columns: [column_1, column_2]) }
    let(:column_1) { build(:column, order: 1) }
    let(:column_2) { build(:column, order: 2) }

    context :true do
      let(:column) { board.columns.last }
      it { is_expected.to eq true }
    end

    context :false do
      let(:column) { board.columns.first }
      it { is_expected.to eq false }
    end
  end
end
