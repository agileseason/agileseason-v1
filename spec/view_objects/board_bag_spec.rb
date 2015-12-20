describe BoardBag do
  let(:user) { build(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:github_api) { double }
  let(:bag) { BoardBag.new(user, board) }
  let(:issues) { {} }
  before { allow(user).to receive(:github_api).and_return(github_api) }
  before { allow(Cached::Issues).to receive(:call).and_return(issues) }
  before { allow(Boards::DetectRepo).to receive(:call).and_return(OpenStruct.new) }

  describe '#issue' do
    subject { bag.issue(issue.number) }
    let(:issue) { stub_issue(number: 1) }
    before { allow(bag).to receive(:issue_stat_mapper).and_return(double(:[] => nil)) }
    before { allow(github_api).to receive(:issue).and_return(issue) }

    context 'issue in cache' do
      let(:issues) { { issue.number => issue } }

      it { is_expected.to be_present }
      it { is_expected.to be_a(BoardIssue) }

      context 'behavior' do
        before { subject }
        it { expect(github_api).not_to have_received(:issue) }
      end
    end

    context 'issue not in cache' do
      let(:issues) { {} }

      it { is_expected.to be_present }
      it { is_expected.to be_a(BoardIssue) }

      context 'behavior' do
        before { subject }
        it { expect(github_api).to have_received(:issue) }
      end
    end
  end

  describe '#issues_by_columns' do
    subject { bag.issues_by_columns }
    let(:column_1) { board.columns.first }
    let(:column_2) { board.columns.second }

    context :empty_columns do
      let(:issues) { {} }

      it { is_expected.to have(2).items }
      it { expect(subject.first.first).to eq column_1.id }
      it { expect(subject[column_1.id]).to be_empty }
      it { expect(subject[column_2.id]).to be_empty }
    end

    context :columns_with_issues do
      let(:issue_1) { stub_issue(number: 1) }
      let(:issue_2) { stub_issue(number: 2) }
      let!(:issue_stat) do
        create(:issue_stat, number: issue_1.number, board: board, column: column_2)
      end
      let(:issues) { { issue_1.number => issue_1, issue_2.number => issue_2 } }

      context 'known issues dont move to first column' do
        it { expect(subject[column_2.id]).to have(1).items }
        it { expect(subject[column_2.id].first.issue).to eq issue_1 }
      end

      context 'unknown open issues added to first column' do
        it { expect(subject[column_1.id]).to have(1).item }
        it { expect(subject[column_1.id].first.issue).to eq issue_2 }
      end
    end
  end

  describe '#collaborators' do
    let(:github_api) { double(collaborators: []) }
    before { allow(bag).to receive(:has_write_permission?).and_return(true) }
    before { bag.collaborators }

    it { expect(github_api).to have_received(:collaborators).with(board) }
  end

  describe '#labels' do
    let(:github_api) { double(labels: []) }
    after { bag.labels }

    it { expect(github_api).to receive(:labels).with(board) }
  end

  describe '#build_issue_new' do
    subject { bag.build_issue_new }
    let(:github_api) { double(labels: [OpenStruct.new(name: 'label_1')]) }

    it { is_expected.to_not be_nil }
    it { is_expected.to be_a(Issue) }
    its(:labels) { is_expected.to eq ['label_1'] }
  end

  describe '#column_issues' do
    subject { bag.column_issues(column_1) }
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

    context 'with partial column.issues - unknown added to tail' do
      let(:issues) { [github_issue_2.number.to_s] }
      it { is_expected.to have(2).items }
      it { expect(subject.first).to eq github_issue_2 }
      it { expect(subject.last).to eq github_issue_1 }
    end
  end

  describe '#private_repo?' do
    subject { bag.private_repo? }
    before { allow(Boards::DetectRepo).to receive(:call).and_return(repo) }

    context 'known repo' do
      let(:repo) { OpenStruct.new(id: board.github_id, private: is_private) }

      context 'private repo' do
        let(:is_private) { true }
        it { is_expected.to eq true }
      end

      context 'public repo' do
        let(:is_private) { false }
        it { is_expected.to eq false }
      end
    end

    context 'unknown repo' do
      let(:repo) { nil }

      context 'is private in board' do
        it { is_expected.to eq true }
      end

      context 'is public in board' do
        let(:board) { create(:board, :with_columns, user: user, is_private_repo: false) }
        it { is_expected.to eq false }
      end
    end
  end

  describe '#has_write_permission?' do
    subject { bag.has_write_permission? }
    before { allow(Boards::DetectRepo).to receive(:call).and_return(repo) }

    context 'known repo' do
      let(:repo) do
        OpenStruct.new(
          id: board.github_id,
          permissions: double(push: is_can_push)
        )
      end

      context 'only read permissions' do
        let(:is_can_push) { false }
        it { is_expected.to eq false }
      end

      context 'write permissions' do
        let(:is_can_push) { true }
        it { is_expected.to eq true }
      end
    end

    context 'unknown repo' do
      let(:repo) { nil }
      it { is_expected.to eq false }
    end
  end

  describe '#has_read_permission?' do
    subject { bag.has_read_permission? }
    let(:board) { create(:board, :with_columns, user: user, is_private_repo: is_private_repo) }
    before { allow(Boards::DetectRepo).to receive(:call).and_return(repo) }

    context 'unknown repo' do
      let(:repo) { nil }

      context 'public repo' do
        let(:is_private_repo) { false }
        it { is_expected.to eq true }
      end

      context 'private repo' do
        let(:is_private_repo) { true }
        it { is_expected.to eq false }
      end
    end
  end

  describe '#subscribed?' do
    subject { bag.subscribed? }

    context 'public repo' do
      before { allow(bag).to receive(:private_repo?).and_return(false) }
      it { is_expected.to eq true }
    end

    context 'private repo' do
      let(:board) { build(:board, subscribed_at: subscribed_at) }
      before { allow(bag).to receive(:private_repo?).and_return(true) }

      context 'active subscription' do
        let(:subscribed_at) { Time.current + 1.day }
        it { is_expected.to eq true }
      end

      context 'not active subscription' do
        let(:subscribed_at) { nil }
        it { is_expected.to eq false }
      end

      context 'old subscription' do
        let(:subscribed_at) { Time.current - 1.day }
        it { is_expected.to eq false }
      end
    end
  end
end
