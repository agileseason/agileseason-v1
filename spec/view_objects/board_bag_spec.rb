describe BoardBag do
  let(:user) { build(:user) }
  let(:board) { build(:board, user: user) }
  let(:github_api) { GithubApi.new('fake_token', user) }
  let(:bag) { BoardBag.new(github_api, board) }

  describe '#issues' do
    before { allow_any_instance_of(GithubApi).to receive(:board_issues) }
    after { bag.issues }

    it { expect_any_instance_of(GithubApi).to receive(:board_issues) }
  end

  describe '#collaborators' do
    before { allow_any_instance_of(GithubApi).to receive(:collaborators) }
    after { bag.collaborators }

    it { expect_any_instance_of(GithubApi).to receive(:collaborators) }
  end

  describe '#labels' do
    before { allow_any_instance_of(GithubApi).to receive(:labels) }
    after { bag.labels }

    it { expect_any_instance_of(GithubApi).to receive(:labels) }
  end
end
