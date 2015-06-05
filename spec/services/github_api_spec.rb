describe GithubApi do
  describe '#github_token' do
    subject { api.github_token }
    let(:api) { GithubApi.new(token) }
    let(:token) { 'asdf' }

    it { is_expected.to eq token }
  end
end
