describe GithubApiGuest do
  let(:api) { GithubApiGuest.new }

  describe '#cached_repos' do
    subject { api.cached_repos }
    it { is_expected.to be_empty }
  end

  describe '#issue' do
    subject { api.issue(nil, 1) }
    it { expect { subject }.to raise_error NoGuestDataError }
  end
end
