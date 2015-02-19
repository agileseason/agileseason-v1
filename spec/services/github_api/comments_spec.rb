describe GithubApi::Comments do
  let(:service) { GithubApi.new('fake_github_token') }
  let(:board) { build(:board, github_id: 1) }
  let(:issue) { OpenStruct.new(number: 1) }

  let(:issue_comments) { [issue_comment_1, issue_comment_2] }
  let(:issue_comment_1) do
    OpenStruct
      .new(body: 'some example of code ```return blah;``` and comment')
  end
  let(:issue_comment_2) { OpenStruct.new(body: 'some comment') }

  describe '#issue_comments' do
    before do
      allow_any_instance_of(Octokit::Client)
        .to receive(:issue_comments)
        .and_return(issue_comments)
    end
    subject { service.issue_comments(board, issue.number) }
    it { is_expected.to have(2).items }
  end

  describe '#update_comment' do
    let(:issue_comment_1) do
      OpenStruct
        .new(body: 'some comment', id: 123435345)
    end
    before do
      allow_any_instance_of(Octokit::Client)
        .to receive(:update_comment)
        .and_return(issue_comment_1)
    end
    subject { service.update_comment(board, issue_comment_1.id, 'new comment') }
    it { is_expected.to eq issue_comment_1 }
  end

  describe '#delete_comment' do
    let(:issue_comment_1) do
      OpenStruct
        .new(body: 'some comment', id: 14234235345)
    end
    before do
      allow_any_instance_of(Octokit::Client)
        .to receive(:delete_comment)
        .and_return(true)
    end
    subject { service.delete_comment(board, issue_comment_1.id) }
    it { is_expected.to eq true }
  end
end
