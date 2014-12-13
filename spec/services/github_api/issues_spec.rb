require "rails_helper"

RSpec.describe GithubApi::Issues do
  let(:service) { GithubApi.new("fake_github_token") }

  describe ".board_issues" do
    subject { service.board_issues(board) }
    let(:board) { build(:board, :with_columns, number_of_columns: 2) }
    before { allow_any_instance_of(Octokit::Client).to receive(:issues).and_return([]) }

    it { is_expected.to have(2).items }
    it { expect(subject.first.first).to eq board.columns.first.label_name }
  end
end
