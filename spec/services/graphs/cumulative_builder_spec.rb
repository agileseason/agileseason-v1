describe Graphs::CumulativeBuilder do
  let(:service) { Graphs::CumulativeBuilder.new(board) }
  let(:board) { create(:kanban_board, :with_columns) }

  describe '#series' do
    subject(:series) { service.series }
    let(:column) { board.columns.first }

    context :empty do
      it { is_expected.to_not be_nil }
      it { is_expected.to_not be_empty }
      it { expect(subject[column.id]).to_not be_empty }
      it { expect(subject[column.id][:name]).to eq column.name }
      it { expect(subject[column.id][:data]).to eq [] }
    end

    context 'one day history' do
      let(:history_data) { [{ column_id: column.id, issues: 1, issues_cumulative: 1 }] }
      let(:column_series) { series[column.id] }
      before { create(:board_history, board: board, data: history_data) }

      describe :name do
        subject { column_series[:name] }
        it { is_expected.to eq column.name }
      end

      describe :data, focus: true do
        subject(:data) { column_series[:data] }
        it { is_expected.to have(2).item }

        describe :first do
          subject { data.first }
          it { expect(subject[:column_id]).to eq column.id }
          it { expect(subject[:issues]).to eq 0 }
          it { expect(subject[:issues_cumulative]).to eq 0 }
          # FIX : timezone diff
          #it { expect(subject[:collected_on]).to eq (Date.today - 1).to_time.utc.to_i * 1000 }
        end

        describe :second do
          subject { data.second }
          it { expect(subject[:column_id]).to eq column.id }
          it { expect(subject[:issues]).to eq 1 }
          it { expect(subject[:issues_cumulative]).to eq 1 }
          # FIX : timezone diff
          #it { expect(subject[:collected_on]).to eq (Date.today).to_time.utc.to_i * 1000 }
        end
      end
    end
  end
end
