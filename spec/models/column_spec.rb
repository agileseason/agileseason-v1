RSpec.describe Column, type: :model do
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
end
