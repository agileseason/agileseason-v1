describe GithubApi::Issues do
  let(:service) { GithubApi.new('fake_token', user) }
  let(:user) { create(:user) }
  let(:board) { build(:board, :with_columns, number_of_columns: 1) }
  let(:issue) { stub_issue }

  describe '#issues' do
    subject { service.issues(board) }
    before do
      allow_any_instance_of(Octokit::Client)
        .to receive(:issues).with(board.github_id).and_return(open_issues)
    end
    before { Timecop.freeze(Time.current) }
    before do
      allow_any_instance_of(Octokit::Client).
        to receive(:issues).
        with(board.github_id, state: :closed, since: 2.month.ago.iso8601).
        and_return(closed_issues)
    end
    after { Timecop.return }

    context 'open and closed' do
      let(:open_issues) { [stub_issue] }
      let(:closed_issues) { [stub_closed_issue] }
      it { is_expected.to eq open_issues + closed_issues }
    end

    context 'without pull request' do
      let(:open_issues) { [stub_pull_request_issue] }
      let(:closed_issues) { [stub_pull_request_issue] }
      it { is_expected.to be_empty }
    end
  end

  describe '#create_issue' do
    subject { service.create_issue(board, issue) }
    let(:board) { create(:board, :with_columns, number_of_columns: 2) }
    let(:issue) { stub_issue(labels: labels) }
    let(:labels) { ['bug', 'feature'] }
    let(:expected_labels) { ['bug', 'feature'] }
    before do
      allow_any_instance_of(Octokit::Client).
        to receive(:create_issue).and_return(issue)
    end
    after { subject }

    it { is_expected.to eq issue }
    it do
      expect_any_instance_of(Octokit::Client).to(
        receive(:create_issue)
          .with(board.github_id, issue.title, issue.body, labels: expected_labels))
    end
  end

  describe '#close' do
    subject { service.close(board, issue.number) }
    before do
      allow_any_instance_of(Octokit::Client).
        to receive(:close_issue).and_return(issue)
    end
    after { subject }

    it { is_expected.to eq issue }
    it do
      expect_any_instance_of(Octokit::Client).
        to receive(:close_issue).with(board.github_id, issue.number)
    end
  end

  describe '#reopen' do
    subject { service.reopen(board, issue.number) }
    before do
      allow_any_instance_of(Octokit::Client).
        to receive(:reopen_issue).and_return(issue)
    end
    after { subject }

    it { is_expected.to eq issue }
    it do
      expect_any_instance_of(Octokit::Client).
        to receive(:reopen_issue).with(board.github_id, issue.number)
    end
  end

  describe '#assign' do
    subject { service.assign(board, issue.number, user.github_username) }
    before { allow_any_instance_of(Octokit::Client).to receive(:issue).and_return(issue) }
    before { allow_any_instance_of(Octokit::Client).to receive(:update_issue).and_return(issue) }

    it { is_expected.to eq issue }
  end

  describe '#search_issues' do
    subject { service.search_issues(board, query) }
    let(:query) { 'test in:title' }
    let(:result) { OpenStruct.new(items: []) }
    before { allow_any_instance_of(Octokit::Client).to receive(:search_issues).and_return(result) }
    after { subject }
    it { is_expected.to be_empty }
    it do
      expect_any_instance_of(Octokit::Client).to receive(:search_issues).
        with("#{query} type:issue repo:#{board.github_full_name}")
    end
  end
end
