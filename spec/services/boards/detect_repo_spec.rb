describe Boards::DetectRepo do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user, github_id: 101) }
  let(:github_api) { double(cached_repos: [repo_1, repo_2]) }
  let(:repo_1) { OpenStruct.new(id: 100) }
  let(:repo_2) { OpenStruct.new(id: board.github_id) }
  before { allow(user).to receive(:github_api).and_return(github_api) }

  describe '#call' do
    subject do
      Boards::DetectRepo.call(
        user: user,
        board: board
      )
    end

    it { is_expected.to be_present }
    it { is_expected.to eq repo_2 }
  end
end
