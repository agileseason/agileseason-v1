describe User do
  describe 'relations' do
    it { is_expected.to have_many(:subscriptions) }
  end

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

  describe '#admin?' do
    subject { user.admin? }
    let(:user) { build(:user, id: id) }

    context 'admins' do
      [User::BLACKCHESTNUT_ID, User::SFOLT_ID].each do |id|
        let(:id) { id }
        it { is_expected.to eq true }
      end
    end

    context 'simple user' do
      let(:id) { 5 }
      it { is_expected.to eq false }
    end
  end

  describe '#guest?' do
    subject { user.guest? }

    context 'true' do
      let(:user) { build :user, id: nil }
      it { is_expected.to eq true }
    end

    context 'false' do
      let(:user) { build :user, id: 1 }
      it { is_expected.to eq false }
    end
  end

  describe '#github_url' do
    subject { user.github_url }

    context 'real user' do
      let(:user) { build_stubbed(:user, github_username: 'blackchestnut') }
      it { is_expected.to eq 'https://github.com/blackchestnut' }
    end

    context 'guest' do
      let(:user) { build(:user, github_username: 'blackchestnut') }
      it { is_expected.to eq '#' }
    end
  end
end
