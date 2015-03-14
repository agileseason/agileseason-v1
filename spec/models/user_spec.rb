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

  describe '#owner?' do
    subject { user.owner?(board) }
    let(:user) { create(:user) }

    context :true do
      let!(:board) { create(:board, :with_columns, user: user) }
      it { is_expected.to eq true }
    end

    context :false do
      let!(:board) { create(:board, :with_columns) }
      it { is_expected.to eq false }
    end
  end
end
