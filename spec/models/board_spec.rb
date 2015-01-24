describe Board, type: :model do
  describe :validates do
    subject { Board.new }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :type }
    it { is_expected.to validate_presence_of :columns }
  end

  describe '.column_labels' do
    let(:column_1) { build(:column, name: "backlog", order: 1) }
    let(:column_2) { build(:column, name: "todo", order: 2) }
    let(:board) { build(:board, columns: [column_1, column_2]) }
    subject { board.column_labels }
    it { is_expected.to eq ["[1] backlog", "[2] todo"] }
  end

  describe '.to_param' do
    let(:board) { build(:board, github_name: 'agileseason') }
    subject { board.to_param }

    it { is_expected.to eq board.github_name }
  end

  describe 'check issue_stats order - important for workers' do
    let(:board) { create(:board, :with_columns) }
    let!(:stat_1) { create(:issue_stat, board: board, number: 2) }
    let!(:stat_2) { create(:issue_stat, board: board, number: 1) }
    subject { board.issue_stats }
    it { is_expected.to eq [stat_2, stat_1] }
  end

  describe '#kanban?' do
    subject { board.kanban? }

    context :true do
      let(:board) { build(:kanban_board) }
      it { is_expected.to eq true }
    end

    context :false do
      let(:board) { build(:scrum_board) }
      it { is_expected.to eq false }
    end
  end

  describe '#scrum?' do
    subject { board.scrum? }

    context :true do
      let(:board) { build(:scrum_board) }
      it { is_expected.to eq true }
    end

    context :false do
      let(:board) { build(:kanban_board) }
      it { is_expected.to eq false }
    end
  end

  describe '#settings' do
    subject { board.settings }
    context :null do
      let(:board) { build(:board) }
      it { is_expected.to eq({}) }
    end

    context :not_null do
      let(:board) { build(:board, settings: { test: 'test' }) }
      it { is_expected.to eq({ test: 'test' }) }
    end

    context :scrum do
      describe '#days_per_iteration' do
        subject { board.days_per_iteration }
        let(:board) { create(:scrum_board, :with_columns) }
        context :default do
          it { is_expected.to eq 14 }
        end

        context :after_edit do
          before { board.days_per_iteration = 7 }
          it { is_expected.to eq 7 }
        end
      end
    end
  end
end
