describe BoardPresenter do
  let(:presenter) { present(:board, board) }
  describe '#name' do
    subject { presenter.name }
    context 'unknown type' do
      let(:board) { build(:board, name: 'test', type: nil) }
      it { is_expected.to eq "#{board.name}&nbsp;" }
    end

    context 'kanban' do
      let(:board) { build(:kanban_board, name: 'test') }
      it { is_expected.to eq "test&nbsp;kanban" }
    end

    context 'scrum' do
      let(:board) { build(:scrum_board, name: 'test') }
      it { is_expected.to eq "test&nbsp;scrum" }
    end

    context 'name with whitespace' do
      let(:board) { build(:kanban_board, name: 'test test') }
      it { is_expected.to eq "test&nbsp;test&nbsp;kanban" }
    end
  end
end
