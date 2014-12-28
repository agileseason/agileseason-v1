RSpec.describe Graphs::LinesWorker do
  let(:worker) { Graphs::LinesWorker.new }

  describe '.perform' do
    subject { board.repo_histories }
    let(:board) { create(:board, :with_columns) }
    let(:perform) { worker.perform(board.id, 'fake_github_token') }
    let(:lines) { 1091 }
    let(:repo_history) {}
    before { allow_any_instance_of(GithubApi).to receive(:repo_lines).and_return(lines) }
    before { repo_history }
    before { perform }

    context :create_repo_history do
      it { is_expected.to have(1).item }
      it { expect(subject.first.lines).to eq lines }
    end

    # NOTE : Обнаружил правающий баг с не получением статистики по строчкам из-за чего сохранялся 0.
    # NOTE : Такое решение может привести к невозможности увести количество строк в 0, но на это сознательно идем.
    context :not_create_repo_history_for_zero_lines do
      let(:lines) { 0 }
      it { is_expected.to be_blank }
    end

    context :update_repo_history do
      let(:repo_history) { create(:repo_history, board: board, collected_on: Date.today, lines: 20) }
      it { expect(subject.first.lines).to eq lines }
    end

    context :create_repo_history_for_other_day do
      let(:repo_history) { create(:repo_history, board: board, collected_on: Date.today.prev_day, lines: 20) }
      it { is_expected.to have(2).item }
    end

    context :create_repo_history_for_missing_days do
      let(:repo_history) { create(:repo_history, board: board, collected_on: Date.today.prev_day(2), lines: 20) }
      it { expect(board.reload.repo_histories).to have(3).item }
    end
  end
end
