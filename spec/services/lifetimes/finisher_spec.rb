describe Lifetimes::Finisher do
  let(:finisher) { Lifetimes::Finisher.new(issue_stat) }

  describe '#call' do
    let(:issue_stat) { create(:issue_stat) }
    let(:prev_out_at) { 1.day.ago.beginning_of_day }
    let!(:lifetime_finished) { create(:lifetime, issue_stat: issue_stat, out_at: prev_out_at) }
    let!(:lifetime_to_finish) { create(:lifetime, issue_stat: issue_stat, out_at: nil) }
    before { finisher.call }

    it { expect(issue_stat.lifetimes.where(out_at: nil)).to be_blank }
    it { expect(lifetime_finished.reload.out_at).to eq prev_out_at }
  end
end
