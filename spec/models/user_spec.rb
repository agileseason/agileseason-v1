describe User, type: :model do
  describe '#login' do
    subject { user.login }
    let(:user) { build(:user, github_username: 'gh_user') }
    it { is_expected.to eq user.github_username }
  end

  describe '#to_s' do
    let(:user) { build(:user, github_username: 'gh_user') }
    subject { user.to_s }
    it { is_expected.to eq user.github_username }
  end

  describe '#repo_admin?' do
    let(:repo) { OpenStruct.new(id: 1, permissions: permissions) }
    let(:permissions) { OpenStruct.new(admin: is_admin) }
    let(:user) { build(:user) }
    before { user.github_api = GithubApi.new('fake_token') }
    before do
      allow_any_instance_of(GithubApi).
        to receive(:cached_repos).and_return([repo])
    end
    subject { user.repo_admin?(repo.id) }

    context :true do
      let(:is_admin) { true }
      it { is_expected.to eq true }
    end

    context :false do
      let(:is_admin) { false }
      it { is_expected.to eq false }
    end
  end
end
