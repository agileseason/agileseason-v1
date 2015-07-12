describe Column do
  describe 'validations' do
    subject { Column.new }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :board }
  end

  describe '#next_columns' do
    let(:board) { create(:board, :with_columns, number_of_columns: 3) }
    let(:column_1) { board.columns.first }
    let(:column_2) { board.columns.second }
    let(:column_3) { board.columns.third }
    subject { column.next_columns }

    context :column_1 do
      let(:column) { column_1 }
      it { is_expected.to eq [column_2, column_3] }
    end

    context :column_2 do
      let(:column) { column_2 }
      it { is_expected.to eq [column_3] }
    end

    context :column_3 do
      let(:column) { column_3 }
      it { is_expected.to be_empty }
    end
  end

  describe '#prev_columns' do
    let(:board) { create(:board, :with_columns, number_of_columns: 3) }
    let(:column_1) { board.columns.first }
    let(:column_2) { board.columns.second }
    let(:column_3) { board.columns.third }
    subject { column.prev_columns }

    context :column_1 do
      let(:column) { column_1 }
      it { is_expected.to be_empty }
    end

    context :column_2 do
      let(:column) { column_2 }
      it { is_expected.to eq [column_1] }
    end

    context :column_3 do
      let(:column) { column_3 }
      it { is_expected.to eq [column_1, column_2] }
    end
  end

  describe '#issues' do
    subject { column.issues }
    let(:column) { build(:column, issues: issues) }
    context 'is nil' do
      let(:issues) { nil }
      it { is_expected.to eq [] }
    end

    context 'not nil' do
      let(:issues) { ['1'] }
      it { is_expected.to eq issues }
    end
  end

  describe '#issues_stat' do
    subject { board.issue_stats }
    let(:board) { create(:board, :with_columns) }
    let(:column) { board.columns.first }
    let!(:issue_stat) { create(:issue_stat, board: board, column: column) }

    it { is_expected.to eq [issue_stat] }
  end

  describe '#visible_issues_stat' do
    subject { board.visible_issue_stats }
    let(:board) { create(:board, :with_columns) }
    let(:column) { board.columns.first }
    let!(:issue_stat_1) { create(:issue_stat, :open, board: board, column: column) }
    let!(:issue_stat_2) { create(:issue_stat, :closed, board: board, column: column) }
    let!(:issue_stat_3) { create(:issue_stat, :archived, board: board, column: column) }

    it { is_expected.to have(2).items }
  end

  describe '#update_sort_issues' do
    subject { column.reload.issues }
    let(:column) { board.columns.first }
    let(:board) { create(:board, :with_columns) }
    before { column.update_sort_issues(issues) }

    context 'nil' do
      let(:issues) { nil }
      it { is_expected.to eq [] }
    end

    context 'empty' do
      let(:issues) { [] }
      it { is_expected.to eq [] }
    end

    context 'filter "empty" from client' do
      let(:issues) { ['1', 'empty', '3'] }
      it { is_expected.to eq ['1', '3'] }
    end

    context 'numbers to strings' do
      let(:issues) { [1, 2, 3] }
      it { is_expected.to eq ['1', '2', '3'] }
    end
  end
end
