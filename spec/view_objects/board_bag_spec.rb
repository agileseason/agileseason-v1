describe BoardBag do
  let(:user) { build(:user) }
  let(:board) { build(:board, user: user) }
  let(:github_api) { GithubApi.new('fake_token', user) }
  let(:bag) { BoardBag.new(github_api, board) }

  describe '#issues' do
    before { allow_any_instance_of(GithubApi).to receive(:board_issues) }
    after { bag.issues }

    it { expect_any_instance_of(GithubApi).to receive(:board_issues) }
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
      allow_any_instance_of(GithubApi).
        to receive(:board_issues).
        and_return(
          column_1.id => [github_issue_1, github_issue_2, github_issue_3]
        )
    end

    context 'with column.issues' do
      let(:issues) { [github_issue_2.number, github_issue_1.number] }
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
