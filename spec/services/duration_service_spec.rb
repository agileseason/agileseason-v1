describe DurationService do
  let(:board) { create(:board, :with_columns) }
  let(:service) { DurationService.new(board) }

  describe '.fetch_group' do
    subject { service.fetch_group }

    context :empty do
      it { is_expected.to be_blank }
    end

    context 'only open issues' do
      let!(:issue) { create(:issue_stat, :open, board: board) }
      it { is_expected.to be_blank }
    end

    context 'one closed issue' do
      let!(:issue) { create(:issue_stat, created_at: 2.day.ago, closed_at: 1.day.ago, board: board) }
      let(:expected_duration) { (issue.closed_at - issue.created_at).to_i / 86400 + 1 }
      it { is_expected.to have(1).item }
      it { expect(subject.first.first).to eq expected_duration }
      it { expect(subject.first.second).to eq 1 }
    end

    context 'sort by duration' do
      let!(:issue_1) { create(:issue_stat, created_at: 3.day.ago, closed_at: 1.day.ago, board: board) }
      let!(:issue_2) { create(:issue_stat, created_at: 2.day.ago, closed_at: 1.day.ago, board: board) }
      let(:expected_duration_1) { (issue_1.closed_at - issue_1.created_at).to_i / 86400 + 1 }
      let(:expected_duration_2) { (issue_2.closed_at - issue_2.created_at).to_i / 86400 + 1 }
      it { is_expected.to have(2).item }
      it { expect(subject.first.first).to eq expected_duration_2 }
      it { expect(subject.second.first).to eq expected_duration_1 }
    end
  end

  describe '.forecast' do
    subject { service.forecast }

    context 'no issues' do
      it { is_expected.to be_nil }
    end

    context 'no history no forecast' do
      let(:issue) { create(:issue_stat, :open) }
      it { is_expected.to be_nil }
    end

    context 'one closed issue for 1 day, then forecast 1 day by issue' do
      let!(:issue_1) { create(:issue_stat, created_at: 1.day.ago, closed_at: 1.day.ago, board: board) }
      context 'one open issue' do
        let!(:issue_2) { create(:issue_stat, :open, board: board) }
        it { is_expected.to eq 1 }
      end

      context 'two open issue' do
        let!(:open_issues) { create_list(:issue_stat, 2, :open, board: board) }
        it { is_expected.to eq 2 }
      end
    end

    context 'closed [1, 1, 2, 4], open 2 then forecast 2 days by issue' do
      let!(:issue_1) { create(:issue_stat, :closed, created_at: 1.day.ago, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, created_at: 1.day.ago, board: board) }
      let!(:issue_3) { create(:issue_stat, :closed, created_at: 2.day.ago, board: board) }
      let!(:issue_4) { create(:issue_stat, :closed, created_at: 4.day.ago, board: board) }
      let!(:issue_open) { create(:issue_stat, :open, board: board) }
      it { is_expected.to eq 2 }
    end

    context 'Rounding - closed [1, 2], open 2 then forecast 1.5 ~ 2 days by issue' do
      let!(:issue_1) { create(:issue_stat, :closed, created_at: 1.day.ago, board: board) }
      let!(:issue_2) { create(:issue_stat, :closed, created_at: 2.day.ago, board: board) }
      let!(:issue_open) { create(:issue_stat, :open, board: board) }
      it { is_expected.to eq 2 }
    end
  end
end
