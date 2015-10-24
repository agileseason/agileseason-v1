describe Roadmap do
  describe '#call' do
    subject { Roadmap.call(board_bag: board_bag) }
    let(:board_bag) { BoardBag.new(user, board) }
    let(:board) { create(:board, :with_columns) }
    let(:user) { create(:user) }

    context 'empty' do
      it { is_expected.to be_empty }
    end

    context 'with issues' do
      let!(:issue_stat_1) { create(:issue_stat, board: board) }
      let(:github_api) { double(issues: issues) }
      let(:issues) { [issue_1] }
      let(:issue_1) { stub_issue }
      before { allow(user).to receive(:github_api).and_return(github_api) }

      it { is_expected.not_to be_empty }
    end
  end
end
