describe GithubApi::Comments do
  let(:service) { GithubApi.new('fake_github_token') }
  let(:board) { build(:board, github_id: 1) }
  let(:issue) { OpenStruct.new(number: 1) }

  let(:issue_comments) { [issue_comment_1, issue_comment_2] }
  let(:issue_comment_1) { OpenStruct.new(body: 'some example of code ```return blah;``` and comment') }
  let(:issue_comment_2) { OpenStruct.new(body: 'some comment') }

  describe '#issue_comments' do
    before { allow_any_instance_of(Octokit::Client)
      .to receive(:issue_comments)
      .and_return(issue_comments) }
    subject { service.issue_comments(board.github_id, issue.number) }
    it { is_expected.to have(2).items }
  end
end
