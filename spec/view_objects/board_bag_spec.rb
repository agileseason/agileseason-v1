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
end
