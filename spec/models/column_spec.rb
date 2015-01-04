RSpec.describe Column, type: :model do
  describe '.label_name' do
    let(:column) { build(:column, name: "backlog", order: 1) }
    subject { column.label_name }
    it { is_expected.to eq "[1] backlog" }
  end

  describe '.next_columns' do
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

  describe '.prev_columns' do
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
end
