describe Graphs::IssueStatsWorker do
  let(:worker) { Graphs::IssueStatsWorker.new }
  describe '.perform' do
    subject { board.issue_stats }
    let(:board) { create(:board, :with_columns) }
    let(:arrange) {}
    before { allow_any_instance_of(GithubApi).to receive(:issues).and_return(issues) }
    before { arrange }
    before { worker.perform(board.id, 'fake_github_token') }

    context :empty do
      let(:issues) { [] }
      it { is_expected.to be_empty }
    end

    context :add_new do
      let(:issues) { [issue_1, issue_2] }
      let(:issue_1) { OpenStruct.new(number: 1, created_at: Time.current - 1.day, updated_at: Time.current - 6.hours, closed_at: Time.current) }
      let(:issue_2) { OpenStruct.new(number: 2, created_at: Time.current - 1.day, updated_at: Time.current - 6.hours, closed_at: nil) }
      it { expect(subject.map(&:number)).to eq [issue_1.number, issue_2.number] }
      it { expect(subject.map(&:created_at)).to eq [issue_1.created_at, issue_2.created_at] }
      it { expect(subject.map(&:updated_at)).to eq [issue_1.updated_at, issue_2.updated_at] }
      it { expect(subject.map(&:closed_at)).to eq [issue_1.closed_at, issue_2.closed_at] }
    end

    context 'update issue_1.closed_at and add new issue_2' do
      let(:arrange) { board.issue_stats.create!(number: 1, created_at: Time.current - 2.day, updated_at: Time.current - 2.day, closed_at: nil) }
      let(:issues) { [issue_1, issue_2] }
      let(:issue_1) { OpenStruct.new(number: 1, created_at: Time.current - 2.day, updated_at: Time.current - 6.hours, closed_at: Time.current) }
      let(:issue_2) { OpenStruct.new(number: 2, created_at: Time.current - 1.day, updated_at: Time.current - 6.hours, closed_at: nil) }
      it { is_expected.to have(2).items }
      it { expect(subject.map(&:number)).to eq [issue_1.number, issue_2.number] }
      it { expect(subject.map(&:created_at)).to eq [issue_1.created_at, issue_2.created_at] }
      it { expect(subject.map(&:updated_at)).to eq [issue_1.updated_at, issue_2.updated_at] }
      it { expect(subject.map(&:closed_at)).to eq [issue_1.closed_at, issue_2.closed_at] }
    end

    context 'update only if need' do
      let(:updated_at) { Time.current - 2.days }
      let(:arrange) { board.issue_stats.create!(number: 1, created_at: Time.current - 2.days, updated_at: updated_at, closed_at: nil) }
      let(:issues) { [issue_1] }
      context '- need' do
        let(:issue_1) { OpenStruct.new(number: 1, created_at: Time.current - 2.day, updated_at: updated_at + 1.second, closed_at: Time.current) }
        it { expect(subject.first.closed_at).to eq issue_1.closed_at }
      end

      context '- not need' do
        let(:issue_1) { OpenStruct.new(number: 1, created_at: Time.current - 2.day, updated_at: updated_at, closed_at: Time.current) }
        it { expect(subject.first.closed_at).to be_nil }
      end
    end
  end
end
