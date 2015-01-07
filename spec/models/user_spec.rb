describe User, type: :model do
  describe '.to_s' do
    let(:user) { build(:user, github_username: 'gh_user') }
    subject { user.to_s }
    it { is_expected.to eq user.github_username }
  end
end
