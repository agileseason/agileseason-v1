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
      let(:issue_1) { stub_issue(number: 1) }
      let(:issue_2) { stub_issue(number: 2) }
      let!(:issue_stat) do
        create(:issue_stat, number: issue_1.number, board: board, column: column_2)
      end
      before do
        allow_any_instance_of(Octokit::Client).
          to receive(:issues).with(board.github_id).
          and_return([issue_1, issue_2])
      end
      before { Timecop.freeze(Time.current) }
      before do
        allow_any_instance_of(Octokit::Client).
          to receive(:issues).
          with(board.github_id, state: :closed, since: 2.month.ago.iso8601).
          and_return([])
      end
      before do
        allow_any_instance_of(Octokit::Client).
          to receive(:update_issue)
      end
      after { Timecop.return }

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

  describe '#update_cache' do
    subject { bag.issues_hash[101] }
    let(:issue) { stub_issue(number: 101) }

    before do
      allow_any_instance_of(Octokit::Client).
        to receive(:issues).and_return([])
    end
    before { Rails.cache.clear }
    before { data_in_cache }
    before { bag.update_cache(issue) }

    context 'has data in cache' do
      let(:data_in_cache) do
        Rails.cache.write(
          bag.send(:cache_key, :issues_hash),
          nil,
          expires_in: 5.minutes
        )
      end

      it { is_expected.to_not be_nil }
      it { is_expected.to eq issue }
    end

    context 'no data in cache' do
      let(:data_in_cache) { }
      it { is_expected.to be_nil }
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
    subject { bag.build_issue_new }
    let(:labels) { [OpenStruct.new(name: 'label_1')] }
    before do
      allow_any_instance_of(GithubApi).
        to receive(:labels).and_return(labels)
    end

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
  end

  describe '#default_column' do
    subject { bag.default_column }
    let(:board) { create(:board, :with_columns, number_of_columns: 2) }
    let(:column_1) { board.columns.first }

    it { is_expected.to eq column_1 }
  end

  describe '#private_repo?' do
    subject { bag.private_repo? }

    context 'known repo' do
      let(:repo) { OpenStruct.new(full_name: board.github_full_name, private: is_private) }
      before do
        allow(github_api).
          to receive(:cached_repos).
          and_return([repo])
      end

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
      before do
        allow(github_api).
          to receive(:cached_repos).
          and_return([])
      end

      it { is_expected.to eq false }
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
