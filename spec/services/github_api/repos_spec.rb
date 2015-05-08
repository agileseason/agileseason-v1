describe GithubApi::Repos do
  let(:service) { GithubApi.new('fake_token', user) }
  let(:user) { build_stubbed(:user) }

  describe '#collaborators' do
    let(:board) { build(:board, github_id: 123) }
    before do
      allow_any_instance_of(Octokit::Client).
        to receive(:collaborators)
    end

    subject { service.collaborators(board) }
    after { subject }

    it do
      expect_any_instance_of(Octokit::Client).
        to receive(:collaborators).with(board.github_id)
    end
  end
end
