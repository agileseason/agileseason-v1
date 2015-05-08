describe Boards::ScrumBoard, type: :model do
  let(:board) { build(:kanban_board) }

  describe '#rolling_average_window' do
    subject { board.rolling_average_window }

    context 'default' do
      it { is_expected.to eq Boards::KanbanBoard::DEFAULT_ROLLING_AVERAGE_WINDOW }
    end

    context 'sepecific' do
      before { board.rolling_average_window = 5 }
      it { is_expected.to eq 5 }
    end
  end

  describe '#kanban_settings' do
    subject { board.kanban_settings }
    it { is_expected.to_not be_nil }
    it { expect(subject.rolling_average_window).to_not be_zero }
  end
end
