describe IssueStats::Painter do
  describe '#call' do
    subject { IssueStats::Painter.call(user: user, board_bag: board_bag, number: number, color: color) }
    let(:user) { build(:user) }
    let(:board_bag) { BoardBag.new(nil, board) }
    let(:board) { create(:board, :with_columns, user: user) }
    let(:number) { issue.number }
    let(:issue) { stub_issue }
    let(:color) { '#f00' }

    context 'issue_stat is exists' do
      before do
        create(
          :issue_stat,
          board: board,
          number: number,
          color: nil
        )
      end

      its(:color) { is_expected.to eq color }
    end
  end
end
