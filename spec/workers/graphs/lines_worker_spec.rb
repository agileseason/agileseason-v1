RSpec.describe Graphs::LinesWorker do
  let(:worker) { Graphs::LinesWorker.new }

  describe ".perform" do
    subject { board.repo_histories }
    let(:board) { create(:board, :with_columns) }
    let(:perform) { worker.perform(board.id, "fake_github_token") }
    let(:lines) { 1091 }
    before { allow_any_instance_of(GithubApi).to receive(:repo_lines).and_return(lines) }
    before { perform }

    context :create_repo_history do
      it { is_expected.to have(1).item }
      it { expect(subject.first.lines).to eq lines }
    end

    context :update_repo_history do
      let!(:repo_history) { create(:repo_history, board: board, collected_on: Date.today, lines: 20) }
      it { expect(subject.first.lines).to eq lines }
    end

    context :create_repo_history_for_other_day do
      let!(:repo_history) { create(:repo_history, board: board, collected_on: Date.today.prev_day, lines: 20) }
      it { is_expected.to have(2).item }
    end
  end
end
