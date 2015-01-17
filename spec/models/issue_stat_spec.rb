RSpec.describe IssueStat, type: :model do
  describe :validates do
    subject { IssueStat.new }
    it { is_expected.to validate_presence_of :number }
    describe 'issue_stat should be uniq for github issue' do
      it { is_expected.to validate_uniqueness_of :number }
    end
  end

  describe '.closed' do
    subject { board.issue_stats.closed }
    let(:board) { create(:board, :with_columns) }
    let!(:closed_issue) { create(:issue_stat, board: board, closed_at: Time.current) }
    let!(:open_issue) { create(:issue_stat, board: board, closed_at: nil) }
    it { is_expected.to have(1).item }
    it { expect(subject.first).to eq closed_issue }
  end

  describe '#elapsed_time' do
    subject { issue_stat.elapsed_time }
    let(:issue_stat) { build(:issue_stat, created_at: created_at, closed_at: closed_at, board: nil) }
    let(:created_at) { (Date.today - 1.day).to_datetime }

    context :closed do
      let(:closed_at) { Date.today.to_datetime }
      it { is_expected.to eq 1.day }
    end

    context :open do
      before { allow(Time).to receive(:current).and_return((Date.today + 1.hour).to_time) }
      let(:closed_at) { nil }
      it { is_expected.to eq 1.day + 1.hour }
    end
  end

  describe '#elapsed_day' do
    subject { issue_stat.elapsed_days }
    let(:issue_stat) { build(:issue_stat, created_at: created_at, closed_at: closed_at, board: nil) }
    let(:created_at) { (Date.today - 1.day).to_datetime }

    context :closed do
      let(:closed_at) { Date.today.to_datetime }
      it { is_expected.to eq 1 }
    end

    context :open do
      before { allow(Time).to receive(:current).and_return((Date.today + 12.hour).to_time) }
      let(:closed_at) { nil }
      it { is_expected.to eq 1.5 }
    end
  end
end
