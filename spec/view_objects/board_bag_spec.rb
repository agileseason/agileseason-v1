describe BoardBag do
  let(:user) { build(:user) }
  let(:board) { build(:board, user: user) }
  let(:github_api) { GithubApi.new('fake_token', user) }
  let(:bag) { BoardBag.new(github_api, board) }

  describe '#issues_by_columns' do
    subject { bag.issues_by_columns }
    let(:board) { create(:board, :with_columns, number_of_columns: 2) }
    let(:column_1) { board.columns.first }
    let(:column_2) { board.columns.second }

    context :empty_columns do
      before do
        allow_any_instance_of(Octokit::Client).
          to receive(:issues).and_return([])
      end

      it { is_expected.to have(2).items }
      it { expect(subject.first.first).to eq column_1.id }
      it { expect(subject[column_1.id]).to be_empty }
      it { expect(subject[column_2.id]).to be_empty }
    end

    context :columns_with_issues do
      let(:issue) { OpenStruct.new(number: 1, state: state) }
      let!(:issue_stat) { create(:issue_stat, number: issue.number, board: board, column: column) }
      let(:state) { 'open' }
      before do
        allow_any_instance_of(Octokit::Client).
          to receive(:issues).with(board.github_id).and_return([issue])
      end
      before { Timecop.freeze(Time.current) }
      before do
        allow_any_instance_of(Octokit::Client).
          to receive(:issues).
          with(board.github_id, state: :closed, since: 1.month.ago.iso8601).
          and_return([])
      end
      before do
        allow_any_instance_of(Octokit::Client).
          to receive(:update_issue)
      end
      after { Timecop.return }

      context 'unknown open issues added to first column' do
        let(:board) { create(:board, :with_columns) }
        let(:column) { column_1 }
        it { expect(subject[column_1.id]).to have(1).item }
        it { expect(subject[column_1.id].first.issue).to eq issue }
      end

      context 'known issues dont move to first column' do
        let(:column) { column_2 }
        it { expect(subject[column_1.id]).to be_empty }
        it { expect(subject[column_2.id]).to have(1).items }
        it { expect(subject[column_2.id].first.issue).to eq issue }
      end
    end
  end

  describe '#collaborators' do
    before { allow_any_instance_of(GithubApi).to receive(:collaborators) }
    after { bag.collaborators }

    it { expect_any_instance_of(GithubApi).to receive(:collaborators) }
  end

  describe '#labels' do
    before { allow_any_instance_of(GithubApi).to receive(:labels) }
    after { bag.labels }

    it { expect_any_instance_of(GithubApi).to receive(:labels) }
  end

  describe '#build_issue_new' do
    before { allow_any_instance_of(GithubApi).to receive(:labels).and_return(labels) }
    let(:labels) { [OpenStruct.new(name: 'label_1')] }
    subject { bag.build_issue_new }
    it { is_expected.to_not be_nil }
    it { is_expected.to be_a(Issue) }
    its(:labels) { is_expected.to eq ['label_1'] }
  end

  describe '#column_issues' do
    let(:board) { build(:board, columns: [column_1, column_2]) }
    let(:column_1) { build_stubbed(:column, name: 'backlog', order: 1, issues: issues) }
    let(:column_2) { build_stubbed(:column, name: 'todo', order: 2) }
    let(:issue_1_1) do
      build_stubbed(
        :issue_stat,
        column: column_1,
        number: github_issue_1.number
      )
    end
    let(:issue_2_1) do
      build_stubbed(
        :issue_stat,
        column: column_1,
        number: github_issue_2.number
      )
    end
    let(:issue_3_1) do
      build_stubbed(
        :issue_stat,
        column: column_1,
        number: github_issue_3.number,
        archived_at: Time.now
      )
    end
    let(:github_issue_1) { OpenStruct.new(number: 1) }
    let(:github_issue_2) { OpenStruct.new(number: 2) }
    let(:github_issue_3) { OpenStruct.new(number: 3, archive?: true) }
    subject { bag.column_issues(column_1) }
    before do
      allow(bag).
        to receive(:issues_by_columns).
        and_return(
          column_1.id => [github_issue_1, github_issue_2, github_issue_3]
        )
    end

    context 'with column.issues' do
      let(:issues) { [github_issue_2.number.to_s, github_issue_3.number.to_s] }
      it { is_expected.to have(2).items }
      it { expect(subject.first).to eq github_issue_2 }
    end

    context 'without column.issues' do
      let(:issues) { nil }
      it { is_expected.to have(2).items }
      it { expect(subject.first).to eq github_issue_1 }
    end
  end
end
