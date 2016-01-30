describe Modal::User do
  let(:user) { Modal::User.new(github_user) }
  let(:github_user) { stub_user }

  describe '#to_h' do
    subject { user.to_h }

    it do
      is_expected.to eq ({
        id: github_user.id,
        login: github_user.login,
        avatar_url: github_user.avatar_url,
      })
    end
  end
end
