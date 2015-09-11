describe IssueStats::LifetimeFinisher do
  let(:finisher) { IssueStats::LifetimeFinisher.new(issue_stat) }

  describe '#call' do
    let(:issue_stat) { create(:issue_stat) }
    let(:prev_out_at) { Time.current - 1.day }
    let!(:lifetime_finished) { create(:lifetime, issue_stat: issue_stat, out_at: prev_out_at) }
    let!(:lifetime_to_finish) { create(:lifetime, issue_stat: issue_stat, out_at: nil) }
    before { finisher.call }

    it { expect(issue_stat.lifetimes.where(out_at: nil)).to be_blank }
    it { expect(lifetime_finished.reload.out_at).to eq prev_out_at }
  end
end
