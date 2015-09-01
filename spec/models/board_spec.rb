describe Board do
  describe 'relations' do
    it { is_expected.to have_many(:subscriptions) }
  end

  describe 'validations' do
    subject { Board.new }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :type }
    it { is_expected.to validate_presence_of :columns }
    it { is_expected.to validate_presence_of :github_name }
    it { is_expected.to validate_presence_of :github_full_name }
  end

  describe '#github_url' do
    subject { board.github_url }
    let(:board) { build(:board, github_full_name: 'agileseason/agileseason') }
    it { is_expected.to eq 'https://github.com/agileseason/agileseason' }
  end

  describe '#activities' do
    subject { board.activities }
    let(:board) { create(:board_with_columns) }

    context :without_activities do
      it { is_expected.to be_empty }
    end

    context :with_activities do
      let!(:activity_1) { create(:archive_activity, board: board) }
      let!(:activity_2) { create(:column_changed_activity, board: board) }
      it { is_expected.to have(2).items }
    end
  end

  describe '#to_param' do
    let(:board) { build(:board, github_name: 'agileseason') }
    subject { board.to_param }

    it { is_expected.to eq board.github_full_name }
  end

  describe '#kanban?' do
    subject { board.kanban? }

    context :true do
      let(:board) { build(:kanban_board) }
      it { is_expected.to eq true }
    end

    context :false do
      let(:board) { build(:scrum_board) }
      it { is_expected.to eq false }
    end
  end

  describe '#scrum?' do
    subject { board.scrum? }

    context :true do
      let(:board) { build(:scrum_board) }
      it { is_expected.to eq true }
    end

    context :false do
      let(:board) { build(:kanban_board) }
      it { is_expected.to eq false }
    end
  end

  describe '#settings' do
    subject { board.settings }
    context :null do
      let(:board) { build(:board) }
      it { is_expected.to eq({}) }
    end

    context :not_null do
      let(:board) { build(:board, settings: { test: 'test' }) }
      it { is_expected.to eq({ test: 'test' }) }
    end

    context :scrum do
      describe '#days_per_iteration' do
        subject { board.days_per_iteration }
        let(:board) { create(:scrum_board, :with_columns) }
        context :default do
          it { is_expected.to eq 14 }
        end

        context :after_edit do
          before { board.days_per_iteration = 7 }
          it { is_expected.to eq 7 }
        end
      end
    end
  end

  describe '#find_stat' do
    let(:board) { create(:board, :with_columns) }
    let(:issue) { OpenStruct.new(number: 1) }
    let!(:issue_stat) { create(:issue_stat, board: board, number: issue.number) }
    subject { board.find_stat(issue) }
    it { is_expected.to eq issue_stat }
  end

  describe '#public?' do
    subject { board.public? }
    let(:board) { build(:board, is_public: is_public) }

    context :false do
      let(:is_public) { false }
      it { is_expected.to eq false }
    end

    context :true do
      let(:is_public) { true }
      it { is_expected.to eq true }
    end
  end
end
