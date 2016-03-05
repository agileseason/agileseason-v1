describe Graphs::AgeBuilder do
  let(:builder) { Graphs::AgeBuilder.new(board_bag) }

  describe '#chart_data' do
    subject { builder.chart_data }
    let(:board) { build :board, :with_columns }
    let(:user) { build :user }
    let(:board_bag) { BoardBag.new(user, board) }
    before { allow(board_bag).to receive(:board_issues).and_return(issues) }

    context 'without issues' do
      let(:issues) { [] }
      it { is_expected.to be_empty }
    end

    context 'with issues' do
      let(:issue) { stub_issue(created_at: created_at) }
      let(:issue_stat) do
        build(:issue_stat, column: board.columns.first, board: board)
      end
      let(:board_issue) { BoardIssue.new(issue, issue_stat) }
      let(:issues) { [board_issue] }
      let(:created_at) { Time.current }
      before { allow(board_bag).to receive(:labels).and_return([]) }
      before { allow(board_bag).to receive(:collaborators).and_return([]) }

      it { is_expected.not_to be_empty }

      context 'age greate than 1' do
        let(:created_at) { 1.day.ago }

        its(:first) do
          is_expected.to eq(
            index: 1,
            number: issue.number,
            days: 1,
            age: :n0,
            issue: IssuePresenter.new(:issue, board_issue).to_hash(board_bag)
          )
        end
      end

      context 'age less than 1' do
        let(:created_at) { 12.hours.ago }

        its(:first) do
          is_expected.to eq(
            index: 1,
            number: issue.number,
            days: 0.5,
            age: :n0,
            issue: IssuePresenter.new(:issue, board_issue).to_hash(board_bag)
          )
        end
      end
    end
  end
end
