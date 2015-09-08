describe IssueStats::Mover do
  let(:mover) { IssueStats::Mover.new(user, board_bag, column_to, number, is_force_sort) }
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }
  let(:issue) { stub_issue }
  let(:github_api) { double(issue: issue) }
  before { allow(user).to receive(:github_api).and_return(github_api) }

  describe '#call' do
    subject { mover.call }
    let(:number) { issue_stat.number }
    let(:issue_stat) { create(:issue_stat, number: stub_issue.number, board: board, column: column_from) }

    context 'column not changed' do
      let(:column_from) { board.columns.first }
      let(:column_to) { board.columns.first }
      before { column_from.update(issues: [issue_stat.number.to_s]) }

      context 'not force' do
        let(:is_force_sort) { false }
        it { expect { subject }.to change(Lifetime, :count).by(0) }
        it { expect { subject }.to change(Activity, :count).by(0) }
        its(:column) { is_expected.to eq column_from }
        its('column.issues') { is_expected.to eq [issue_stat.number.to_s] }
      end

      context 'force' do
        let(:is_force_sort) { true }
        it { expect { subject }.to change(Lifetime, :count).by(1) }
        it { expect { subject }.to change(Activity, :count).by(0) }
        its(:column) { is_expected.to eq column_from }
        its('column.issues') { is_expected.to eq [issue_stat.number.to_s] }
      end
    end

    context 'column changed' do
      let(:column_from) { board.columns.first }
      let(:column_to) { board.columns.second }

      context 'not force' do
        let(:is_force_sort) { false }

        it { expect { subject }.to change(Lifetime, :count).by(1) }
        it { expect { subject }.to change(Activity, :count).by(1) }
        its(:column) { is_expected.to eq column_to }
      end

      context 'force' do
        let(:is_force_sort) { true }

        it { expect { subject }.to change(Lifetime, :count).by(1) }
        it { expect { subject }.to change(Activity, :count).by(1) }
        its(:column) { is_expected.to eq column_to }
        its('column.issues') { is_expected.to eq [issue_stat.number.to_s] }
      end
    end
  end
end
