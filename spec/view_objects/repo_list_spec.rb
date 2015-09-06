describe RepoList do
  let(:list) { RepoList.new(user) }
  let(:user) { build(:user) }
  let(:github_api) { double(repos: repos) }
  before { allow(user).to receive(:github_api).and_return(github_api) }

  describe '#repos' do
    subject { list.repos }
    let(:repos) { [stub_repo] }

    it { is_expected.to eq repos }
  end

  describe '#menu_repos' do
    subject { list.menu_repos }
    let(:repos) { [repo_public, repo_private, repo_without_permissions] }
    let(:repo_public) { stub_repo }
    let(:repo_private) { stub_repo(private: true) }
    let(:repo_without_permissions) do
      stub_repo(permissions: double(admin: false))
    end

    it { is_expected.to have(2).items }
    its('first.repo') { is_expected.to eq repo_public }
    its('second.repo') { is_expected.to eq repo_private }
  end
end
