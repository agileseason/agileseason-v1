describe Graphs::ForecastBuilder do
  let(:builder) { Graphs::ForecastBuilder.new(board) }

  describe '#categories' do
    subject { builder.categories }
    let(:board) { create(:board, :set_columns, names: ['To Do', 'Done']) }

    it { is_expected.to have(2).items }
  end

  describe '#series_forecast' do
    subject { builder.series_forecast }
    let(:board) { create(:board, :set_columns, names: ['To Do', 'Done']) }

    context 'empty' do
      it { is_expected.to have(2).items }
      it { expect(subject.first[:issues]).to eq 0 }
      it { expect(subject.first[:y]).to eq 0.0 }
      it { expect(subject.last[:issues]).to eq 0 }
      it { expect(subject.last[:y]).to eq 0.0 }
    end

    context 'with issues' do
      let(:column_1) { board.columns.first }
      let(:column_2) { board.columns.last }
      let!(:issue_1_1) { create(:issue_stat, board: board, column: column_1) }
      let!(:issue_1_2) { create(:issue_stat, board: board, column: column_1) }
      let!(:issue_2_1) { create(:issue_stat, board: board, column: column_2) }

      it { is_expected.to have(2).items }
      it { expect(subject.first[:issues]).to eq 2 }
      it { expect(subject.first[:y]).to eq 2.0 }
      it { expect(subject.last[:issues]).to eq 1 }
      it { expect(subject.last[:y]).to eq 1.0 }
    end

    context 'with issues except closed' do
      let(:column_1) { board.columns.first }
      let(:column_2) { board.columns.last }
      let!(:issue_1_1) { create(:issue_stat, :closed, board: board, column: column_1) }
      let!(:issue_1_2) { create(:issue_stat, board: board, column: column_1) }
      let!(:issue_2_1) { create(:issue_stat, :closed, board: board, column: column_2) }

      it { is_expected.to have(2).items }
      it { expect(subject.first[:issues]).to eq 1 }
      it { expect(subject.first[:y]).to eq 1.0 }
      it { expect(subject.last[:issues]).to eq 0 }
      it { expect(subject.last[:y]).to eq 0.0 }
    end
  end

  describe '#series_prev' do
    subject { builder.series_prev }
    let(:board) { create(:board, :set_columns, names: ['To Do', 'Done']) }

    context 'empty' do
      it { is_expected.to have(2).items }
      it { expect(subject.first[:issues]).to eq 0 }
      it { expect(subject.first[:y]).to eq 0.0 }
      it { expect(subject.last[:issues]).to eq 0 }
      it { expect(subject.last[:y]).to eq 0.0 }
    end

    context 'with issues' do
      let(:column_1) { board.columns.first }
      let(:column_2) { board.columns.last }
      let!(:issue_1_1) { create(:issue_stat, board: board, column: column_1) }
      let!(:issue_1_2) { create(:issue_stat, board: board, column: column_1) }
      let!(:issue_2_1) { create(:issue_stat, board: board, column: column_2) }

      it { is_expected.to have(2).items }
      it { expect(subject.first[:issues]).to eq 1 }
      it { expect(subject.first[:y]).to eq 1.0 }
      it { expect(subject.last[:issues]).to eq 0 }
      it { expect(subject.last[:y]).to eq 0.0 }
    end

    context 'with issues except closed' do
      let(:column_1) { board.columns.first }
      let(:column_2) { board.columns.last }
      let!(:issue_1_1) { create(:issue_stat, :closed, board: board, column: column_1) }
      let!(:issue_2_1) { create(:issue_stat, board: board, column: column_2) }
      let!(:issue_2_2) { create(:issue_stat, :closed, board: board, column: column_2) }

      it { is_expected.to have(2).items }
      it { expect(subject.first[:issues]).to eq 1 }
      it { expect(subject.first[:y]).to eq 1.0 }
      it { expect(subject.last[:issues]).to eq 0 }
      it { expect(subject.last[:y]).to eq 0.0 }
    end

    context 'sum y' do
      let(:board) { create(:board, :set_columns, names: ['To Do', 'Test', 'Done']) }
      let(:column_1) { board.columns.first }
      let(:column_2) { board.columns.second }
      let(:column_3) { board.columns.last }
      let!(:issue_1) { create(:issue_stat, board: board, column: column_1) }
      let!(:issue_2) { create(:issue_stat, board: board, column: column_2) }
      let!(:issue_3) { create(:issue_stat, board: board, column: column_3) }

      it { is_expected.to have(3).items }
      it { expect(subject.first[:y]).to eq 2.0 }
      it { expect(subject.second[:y]).to eq 1.0 }
      it { expect(subject.last[:y]).to eq 0.0 }
    end
  end
end
