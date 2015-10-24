describe RoadmapIssue do
  describe '#call' do
    subject do
      RoadmapIssue.call(
        issue_stat: issue_stat,
        free_time_at: free_time_at,
        cycle_time_days: cycle_time_days
      )
    end
    let(:issue) { BoardIssue.new(github_issue, issue_stat) }
    let(:issue_stat) { build(:issue_stat, created_at: created_at, closed_at: closed_at) }
    let(:free_time_at) { Time.parse('2015-10-01') }
    let(:cycle_time_days) { 2 }
    let(:created_at) { free_time_at - 1.day }

    context 'closed' do
      let(:closed_at) { free_time_at + 1.days }

      its(:from) { is_expected.to eq created_at }
      its(:to) { is_expected.to eq closed_at }
      its(:free_time_at) { is_expected.to eq free_time_at }
      its(:cycletime) { is_expected.to eq closed_at - created_at }
    end

    context 'open' do
      let(:closed_at) { nil }

      its(:from) { is_expected.to eq created_at }
      its(:to) { is_expected.to eq free_time_at + cycle_time_days.days }
      its(:free_time_at) { is_expected.to eq free_time_at + cycle_time_days.days }
      its(:cycletime) { is_expected.to eq free_time_at + cycle_time_days.days - created_at }
    end
  end
end
