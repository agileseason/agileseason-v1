describe GithubApi::Issues do
  let(:service) { GithubApi.new('fake_token', user) }
  let(:user) { build_stubbed(:user) }
  let(:board) { build(:board, :with_columns, number_of_columns: 1) }
  let(:issue) { OpenStruct.new(number: 1) }

  describe '#issues' do
    subject { service.issues(board) }
    before do
      allow_any_instance_of(Octokit::Client)
        .to receive(:issues).with(board.github_id).and_return(open_issues)
    end
    before do
      allow_any_instance_of(Octokit::Client)
        .to receive(:issues).with(board.github_id, state: :closed).and_return(closed_issues)
    end

    context 'open and closed' do
      let(:open_issues) { [OpenStruct.new(number: 1)] }
      let(:closed_issues) { [OpenStruct.new(number: 2)] }
      it { is_expected.to eq open_issues + closed_issues }
    end

    context 'without pull request' do
      let(:open_issues) { [OpenStruct.new(number: 1, pull_request: {})] }
      let(:closed_issues) { [OpenStruct.new(number: 2, pull_request: {})] }
      it { is_expected.to be_empty }
    end

    context 'default sort by updated_at' do
      let(:open_issues) { [OpenStruct.new(number: 1, updated_at: 1.day.ago)] }
      let(:closed_issues) { [OpenStruct.new(number: 2, updated_at: 0.day.ago)] }
      it { is_expected.to eq closed_issues + open_issues }
    end
  end

  describe '#board_issues' do
    subject { service.board_issues(board) }
    let(:board) { create(:board, :with_columns, number_of_columns: 2) }
    let(:column_1) { board.columns.first }
    let(:column_2) { board.columns.second }

    context :empty_columns do
      before { allow_any_instance_of(Octokit::Client).to receive(:issues).and_return([]) }

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
        allow_any_instance_of(Octokit::Client)
          .to receive(:issues).with(board.github_id).and_return([issue])
      end
      before do
        allow_any_instance_of(Octokit::Client)
          .to receive(:issues).with(board.github_id, state: :closed).and_return([])
      end
      before do
        allow_any_instance_of(Octokit::Client)
          .to receive(:update_issue)
      end

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

  describe '#create_issue' do
    subject { service.create_issue(board, issue) }
    let(:board) { create(:board, :with_columns, number_of_columns: 2) }
    let(:issue) { OpenStruct.new(number: 1, title: 'title_1', body: 'body_1', labels: labels) }
    let(:labels) { ['bug', 'feature'] }
    let(:expected_labels) { ['bug', 'feature'] }
    before { allow_any_instance_of(Octokit::Client).to receive(:create_issue).and_return(issue) }
    after { subject }

    it do
      expect_any_instance_of(Octokit::Client).to(
        receive(:create_issue)
          .with(board.github_id, issue.title, issue.body, labels: expected_labels))
    end
    it { is_expected.to eq issue }
    it { expect{subject}.to change(IssueStat, :count).by(1) }
  end

  describe '#move_to' do
    subject { service.move_to(board, move_to_column, issue.number) }
    let(:board) { create(:board, :with_columns, user: user) }
    let(:move_to_column) { board.columns.first }
    let(:issue) { OpenStruct.new(number: 1, name: 'issue_1', body: '', labels: ['feature']) }
    before { allow_any_instance_of(Octokit::Client).to receive(:issue).and_return(issue) }
    before { allow(IssueStatService).to receive(:move!) }
    before { allow(Activities::ColumnChangedActivity).to receive(:create_for) }

    after { subject }
    it { expect(IssueStatService).to receive(:move!) }
    # FIX : Check params .with(...)
    it { expect(Activities::ColumnChangedActivity).to receive(:create_for) }
  end

  describe '#close' do
    subject { service.close(board, issue.number) }
    before { allow_any_instance_of(Octokit::Client).to receive(:close_issue).and_return(issue) }
    before { allow_any_instance_of(Octokit::Client).to receive(:issue).and_return(issue) }
    before { allow(IssueStatService).to receive(:close!) }
    after { subject }

    it do
      expect_any_instance_of(Octokit::Client)
        .to receive(:close_issue).with(board.github_id, issue.number)
    end
    it { expect(IssueStatService).to receive(:close!).with(board, issue) }
  end

  describe '#archive' do
    subject { service.archive(board, issue.number) }
    let(:issue) { OpenStruct.new(number: 1, state: state) }
    let(:issue_stat) { create(:issue_stat, board: board) }
    let(:in_at) { Time.current }
    before { allow_any_instance_of(Octokit::Client).to receive(:issue).and_return(issue) }
    before { allow(IssueStatService).to receive(:archive!).and_return(issue_stat) }
    # FIX : Check params .with(...)
    before { allow(Activities::ArchiveActivity).to receive(:create_for) }


    context 'closed issue' do
      let(:state) { 'closed' }
      let(:archived_at) { Time.current }
      before { allow(Time).to receive(:current).and_return(archived_at) }

      after { subject }
      #it { expect(IssueStatService).to receive(:archive!).with(board, issue) }
      #it { expect(Activities::ArchiveActivity).to receive(:create_for) }
      it { expect(subject).to_not be_nil }
      it { expect(subject).to be_a IssueStat }
    end

    context 'open issue' do
      let(:state) { 'open' }
      after { subject }
      it { expect_any_instance_of(Octokit::Client).to_not receive(:update_issue) }
    end
  end

  describe '#assign' do
    subject { service.assign(board, issue.number, user.github_username) }
    before { allow_any_instance_of(Octokit::Client).to receive(:issue).and_return(issue) }
    before { allow_any_instance_of(Octokit::Client).to receive(:update_issue).and_return(issue) }

    it { is_expected.to eq issue }
  end

  describe '#search_issues' do
    subject { service.search_issues(board, query) }
    let(:query) { 'test in:title' }
    let(:result) { OpenStruct.new(items: []) }
    before { allow_any_instance_of(Octokit::Client).to receive(:search_issues).and_return(result) }
    after { subject }
    it { is_expected.to be_empty }
    it do
      expect_any_instance_of(Octokit::Client).to receive(:search_issues).
        with("#{query} type:issue repo:#{board.github_full_name}")
    end
  end
end
