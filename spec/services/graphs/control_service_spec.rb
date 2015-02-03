describe Graphs::ControlService do
  let(:service) { Graphs::ControlService.new(board) }
  let(:board) { create(:kanban_board, :with_columns) }

  describe '#issues_series_data' do
    subject { service.issues_series_data }
    context :empty do
      it { is_expected.to be_empty }
    end

    context :not_empty do
      let!(:open_issue) { create(:issue_stat, :open, board: board) }
      let!(:closed_issue) { create(:issue_stat, :closed, board: board) }
      it { is_expected.to have(1).item }
      it { expect(subject.first[:number]).to eq closed_issue.number }
    end
  end

  describe '#average_series_data' do
    subject { service.average_series_data }

    context :empty do
      it { is_expected.to be_empty }
    end

    context 'One issue' do
      let!(:closed_issue) { create(:issue_stat, :closed, board: board) }
      it { is_expected.to have(1).item }
    end

    context 'Several issues - in line onlty two points' do
      let!(:closed_issues) { create_list(:issue_stat, 3, :closed, board: board) }
      it { is_expected.to have(2).items }
    end

    context :order do
      let!(:issue_stat_1) { create(:issue_stat, :closed, number: 1, created_at: 10.days.ago, closed_at: 1.day.ago, board: board) }
      let!(:issue_stat_2) { create(:issue_stat, :closed, number: 2, created_at: 10.days.ago, closed_at: 3.day.ago, board: board) }
      let!(:issue_stat_3) { create(:issue_stat, :closed, number: 3, created_at: 10.days.ago, closed_at: 0.day.ago, board: board) }
      it { expect(subject.first[:x]).to eq issue_stat_2.closed_at.to_js }
      it { expect(subject.last[:x]).to eq issue_stat_3.closed_at.to_js }
    end

    context 'Check average value' do
      let(:first_point) { subject.first[:y].round(2) }
      let(:last_point) { subject.last[:y].round(2) }
      context 'One issue' do
        let!(:closed_issue) { create(:issue_stat, :closed, wip: 2, board: board) }
        it { is_expected.to have(1).item }
        it { expect(first_point).to eq 2 }
        it { expect(last_point).to eq 2 }
      end

      context 'Two issues' do
        let!(:issue_stat_1) { create(:issue_stat, :closed, wip: 1, board: board) }
        let!(:issue_stat_2) { create(:issue_stat, :closed, wip: 2, board: board) }
        it { is_expected.to have(2).items }
        it { expect(first_point).to eq 1.5 }
        it { expect(last_point).to eq 1.5 }
      end
    end
  end

  describe '#rolling_average_series_data' do
    subject { service.rolling_average_series_data }
    let(:rolling_window) { 7 }
    before { board.rolling_average_window = rolling_window }

    context :empty do
      it { is_expected.to be_empty }
    end

    context 'One issue' do
      let!(:closed_issue) { create(:issue_stat, :closed, board: board) }
      it { is_expected.to have(2).item }
      it { expect(subject.first[:y]).to eq 0 }
      it { expect(subject.last[:y]).to_not eq 0 }
    end

    describe 'Test grouping issues by rolling window' do
      context 'Check rolling average groups' do
        let!(:issue_stats) { create_list(:issue_stat, issue_count, :closed, board: board) }

        context 'Issues less than rolling window' do
          let(:issue_count) { rolling_window - 1 }
          it { is_expected.to have(2).item }
        end

        context 'Issues eq rolling window' do
          let(:issue_count) { rolling_window }
          it { is_expected.to have(2).item }
        end

        context 'Issues greate than rolling window' do
          let(:issue_count) { rolling_window + 1 }
          it { is_expected.to have(3).item }
        end
      end
    end

    context 'Check rolling average value' do
      let(:zero_point) { subject.first[:y].round(2) }
      let(:first_point) { subject.second[:y].round(2) }
      let(:last_point) { subject.last[:y].round(2) }
      context 'One issue' do
        let!(:closed_issue) { create(:issue_stat, :closed, wip: 2, board: board) }
        it { expect(first_point).to eq 2 }
        it { expect(last_point).to eq 2 }
      end

      context 'Two issues - less than window' do
        let!(:issue_stat_1) { create(:issue_stat, :closed, wip: 1, board: board) }
        let!(:issue_stat_2) { create(:issue_stat, :closed, wip: 2, board: board) }
        it { expect(first_point).to eq 1.5 }
        it { expect(last_point).to eq 1.5 }
      end

      context 'Two groups' do
        let!(:issue_stat_0) { create(:issue_stat, :closed, wip: 10, closed_at: 21.day.ago, board: board) }
        let!(:issue_stats_1) do
          create_list(
            :issue_stat,
            rolling_window,
            :closed,
            wip: 10,
            closed_at: 20.day.ago,
            board: board
          )
        end

        let!(:issue_stats_2) do
          create_list(
            :issue_stat,
            rolling_window,
            :closed,
            wip: 2,
            closed_at: 1.day.ago,
            board: board
          )
        end

        it { expect(subject.first[:x]).to eq (21.day.ago).in_time_zone.to_js }
        it { expect(zero_point).to eq 0 }
        it { expect(first_point).to eq 10 }
        it { expect(last_point).to eq 2 }
      end
    end
  end
end
