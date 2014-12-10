require "rails_helper"

RSpec.describe Graphs::CumulativeWorker do
  let(:worker) { Graphs::CumulativeWorker.new }

  describe ".perform" do
    subject { board.board_histories }
    let(:board) { create(:board, :with_columns) }
    let(:perform) { worker.perform(board.id, "fake_github_token") }
    let(:issue) { OpenStruct.new(name: "issue_1") }
    let(:board_issues) { { board.columns.first.label_name => [issue, issue] } }
    before { allow_any_instance_of(GithubApi).to receive(:board_issues).and_return(board_issues) }
    before { perform }

    context :create_board_history do
      let(:expected_data) { [{ column_id: 1, issues: 2 }] }
      it { is_expected.to have(1).item }
      it { expect(subject.first.data).to eq expected_data }
    end
  end
end
