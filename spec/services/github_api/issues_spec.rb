require "rails_helper"

RSpec.describe GithubApi::Issues do
  let(:service) { GithubApi.new("fake_github_token") }
  let(:board) { build(:board, :with_columns, number_of_columns: 1) }
  let(:issue) { OpenStruct.new(number: 1) }

  describe ".board_issues" do
    subject { service.board_issues(board) }
    let(:board) { build(:board, :with_columns, number_of_columns: 2) }
    before { allow_any_instance_of(Octokit::Client).to receive(:issues).and_return([]) }

    it { is_expected.to have(2).items }
    it { expect(subject.first.first).to eq board.columns.first.label_name }
  end

  describe '.create_issue' do
    subject { service.create_issue(board, issue) }
    let(:board) { build(:board, :with_columns, number_of_columns: 2) }
    let(:issue) { OpenStruct.new(title: 'title_1', body: 'body_1', labels: labels) }
    let(:labels) { ['bug', 'feature', ''] }
    let(:expected_body) { issue.body + TrackStats.track(board.columns.first.id) }
    let(:expected_labels) { ['bug', 'feature', board.columns.first.label_name] }
    before { allow_any_instance_of(Octokit::Client).to receive(:create_issue).and_return(issue) }
    after { subject }

    it do
      expect_any_instance_of(Octokit::Client).to(
        receive(:create_issue)
          .with(board.github_id, issue.title, expected_body, labels: expected_labels))
    end
  end

  describe ".move_to" do
    subject { service.move_to(board, column, 1) }
    let(:board) { build(:board, :with_columns, number_of_columns: 1) }
    let(:column) { board.columns.first }
    before { allow_any_instance_of(Octokit::Client).to receive(:issue).and_return(issue) }
    before { allow_any_instance_of(Octokit::Client).to receive(:update_issue).and_return(issue) }

    context :empty_comment do
      let(:issue) { OpenStruct.new(name: "issue_1", body: "", labels: []) }
      it { is_expected.to_not be_nil }
    end
  end

  describe ".close" do
    subject { service.close(board, issue.number) }
    before { allow_any_instance_of(Octokit::Client).to receive(:close_issue).and_return(issue) }

    it { is_expected.to eq issue }
  end

  describe ".assign_yourself" do
    subject { service.assign_yourself(board, issue.number, user.github_username) }
    let(:user) { build(:user) }
    before { allow_any_instance_of(Octokit::Client).to receive(:issue).and_return(issue) }
    before { allow_any_instance_of(Octokit::Client).to receive(:update_issue).and_return(issue) }

    it { is_expected.to eq issue }
  end
end
