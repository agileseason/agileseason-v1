describe GithubApi do
  let(:api) { GithubApi.new(token) }
  let(:token) { 'asdf' }

  describe '#client' do
    subject { api.client }
    let(:client) { double }
    before { allow(Octokit::Client).to receive(:new).and_return client }

    it { is_expected.to eq client }

    context 'behavior' do
      before { subject }
      it do
        expect(Octokit::Client).
          to have_received(:new).
          with(access_token: token, auto_paginate: true)
      end
    end

  end

  describe '#github_token' do
    subject { api.github_token }
    it { is_expected.to eq token }
  end
end
