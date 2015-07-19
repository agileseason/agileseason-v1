describe FrequencyService do
  let(:board) { create(:board, :with_columns, created_at: now - 1.year) }
  let(:now) { Time.local(2015, 1, 1, 0, 0, 0) }
  let(:service) { FrequencyService.new(board, board.created_at) }
  let(:zero_point) { [0, 0] }

  describe '#chart_series' do
    subject { service.chart_series }
    it { is_expected.not_to be_nil }

    context 'empty but have zero point' do
      it { is_expected.to eq FrequencyService::ZERO_POINT }
    end

    context 'only open issues - only zero point again' do
      let!(:issue) { create(:issue_stat, :open, board: board) }
      it { is_expected.to eq FrequencyService::ZERO_POINT }
    end

    context 'one closed issue plus zero point' do
      let!(:issue) { create(:issue_stat, :closed, created_at: 1.day.ago, board: board) }

      it { is_expected.to have(3).items }
      its([0]) { is_expected.to eq 0 }
      its([1]) { is_expected.to eq 0 }
      its([2]) { is_expected.to eq 1 }
    end

    context 'sort by duration (2 points + 1 zero)' do
      let!(:issue_1) { create(:issue_stat, :closed, wip: 2, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, wip: 1, board: board) }

      it { is_expected.to have(3).item }
      its([0]) { is_expected.to eq 0 }
      its([1]) { is_expected.to eq 1 }
      its([2]) { is_expected.to eq 1 }
    end

    context 'sort by duration (1 points + 1 zero)' do
      let!(:issue_1) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, wip: 1, board: board) }

      it { is_expected.to have(3).item }
      its([0]) { is_expected.to eq 0 }
      its([1]) { is_expected.to eq 2 }
    end

    context 'from other board' do
      let(:other_board) { create(:board, :with_columns) }
      let!(:issue_1) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, wip: 1, board: board) }

      it { is_expected.to eq FrequencyService::ZERO_POINT }
    end
  end

  describe '#avg_lifetime' do
    subject { service.avg_lifetime }

    context 'no closed issues' do
      let!(:issue_open) { create(:issue_stat, :open, board: board) }
      it { is_expected.to be_nil }
    end

    context 'Rounding - closed [1, 2], open 2 then elapsed 1.50' do
      let!(:issue_1) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, wip: 2, board: board) }
      let!(:issue_open) { create(:issue_stat, :open, board: board) }
      it { is_expected.to eq 1.5 }
    end
  end

  describe '#avg_lifetime_percentile' do
    subject { service.avg_lifetime_percentile(persentile) }
    let(:persentile) { 0.8 }

    context 'without closed issues' do
      let!(:issue_open) { create(:issue_stat, :open, board: board) }
      it { is_expected.to be_nil }
    end

    context 'one issue' do
      let!(:issue_1) { create(:issue_stat, :closed, wip: 1, board: board) }
      it { is_expected.to eq 1 }
    end

    context 'only in percentile' do
      let!(:issue_1) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_3) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_4) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_5) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_6) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_7) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_8) { create(:issue_stat, :closed, wip: 1, board: board) }
      let!(:issue_9) { create(:issue_stat, :closed, wip: 19, board: board) }
      let!(:issue_0) { create(:issue_stat, :closed, wip: 20, board: board) }

      it { is_expected.to eq 1 }
    end
  end

  describe '#throughput' do
    subject { service.throughput }
    let(:board) { create(:board, :with_columns, created_at: now - 1.month) }

    context 'without issues' do
      it { is_expected.to be_nil }
    end

    context 'with issues' do
      before { Timecop.freeze(now) }
      after { Timecop.return }

      context 'one closed issue' do
        let!(:issue_1) do
          create(
            :issue_stat,
            :closed,
            board: board,
            created_at: 2.day.ago,
            closed_at: 1.day.ago
          )
        end

        it { is_expected.to eq 1 / 31.0 }
      end

      context 'two closed issues' do
        let!(:issue_1) do
          create(
            :issue_stat,
            :closed,
            board: board,
            created_at: 15.days.ago,
            closed_at: 15.days.ago + 1.day
          )
        end
        let!(:issue_2) do
          create(
            :issue_stat,
            :closed,
            board: board,
            created_at: 2.day.ago,
            closed_at: 1.day.ago
          )
        end

        it { is_expected.to eq (1 + 1) / 31.0 }
      end
    end
  end
end
