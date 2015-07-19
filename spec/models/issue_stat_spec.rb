RSpec.describe IssueStat, type: :model do
  describe 'validations' do
    subject { IssueStat.new }
    it { is_expected.to validate_presence_of :number }

    describe 'issue_stat should be uniq for github issue' do
      it { is_expected.to validate_uniqueness_of :number }
    end
  end

  describe 'scopes' do
    describe '.open' do
      subject { board.issue_stats.open }
      let(:board) { create(:board, :with_columns) }
      let!(:closed_issues) { create(:issue_stat, board: board, closed_at: Time.current) }
      let!(:open_issue) { create(:issue_stat, board: board, closed_at: nil) }

      it { is_expected.to have(1).item }
      it { expect(subject.first).to eq open_issue }
    end

    describe '.closed' do
      subject { board.issue_stats.closed }
      let(:board) { create(:board, :with_columns) }
      let!(:closed_issue) { create(:issue_stat, board: board, closed_at: Time.current) }
      let!(:open_issue) { create(:issue_stat, board: board, closed_at: nil) }

      it { is_expected.to have(1).item }
      it { expect(subject.first).to eq closed_issue }
    end

    describe '.archived' do
      subject { board.issue_stats.archived }
      let(:board) { create(:board, :with_columns) }
      let!(:open_issue) { create(:issue_stat, board: board, closed_at: nil) }
      let!(:closed_issue) { create(:issue_stat, board: board, closed_at: Time.current) }
      let!(:archived_issue) { create(:issue_stat, board: board, archived_at: Time.current) }

      it { is_expected.to have(1).item }
      it { expect(subject.first).to eq archived_issue }
    end
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

  describe '#closed?' do
    subject { issue_stat.closed? }

    context :false do
      let(:issue_stat) { build(:issue_stat, closed_at: nil) }
      it { is_expected.to eq false }
    end

    context :true do
      let(:issue_stat) { build(:issue_stat, closed_at: Time.current) }
      it { is_expected.to eq true }
    end
  end

  describe '#archived?' do
    subject { issue_stat.archived? }

    context :false do
      let(:issue_stat) { build(:issue_stat, archived_at: nil) }
      it { is_expected.to eq false }
    end

    context :true do
      let(:issue_stat) { build(:issue_stat, archived_at: Time.current) }
      it { is_expected.to eq true }
    end
  end
end
