describe ApplicationHelper do
  describe '.github_avatar_url' do
    subject { helper.github_avatar_url(user) }
    let(:user) { build(:user, github_username: 'test-x') }

    it { is_expected.to eq 'https://avatars.githubusercontent.com/test-x' }
  end
end
