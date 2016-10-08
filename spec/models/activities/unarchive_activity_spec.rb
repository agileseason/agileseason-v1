describe Activities::UnarchiveActivity, type: :model do
  describe '.create_for' do
    subject(:activity) do
      Activities::UnarchiveActivity.create_for(issue_stat, user)
    end
    let(:user) { build(:user) }
    let(:board) { build(:kanban_board, :with_columns, user: user) }
    let(:issue_stat) { build(:issue_stat, board: board) }

    it { expect { subject }.to change(Activities::UnarchiveActivity, :count).by(1) }
    its(:board) { is_expected.to eq board }
    its(:issue_stat) { is_expected.to eq issue_stat }
    its(:data) { is_expected.to be_nil }

    describe '#dscription' do
      subject { activity.description(issue_url).prettify }
      let(:issue_url) { '/1' }

      it do
        is_expected.to eq(
          "<a href='#' class='issue-ajax' \
            data-number='5' data-turbolinks='false' \
            data-url='/1'>issue&nbsp;##{issue_stat.number}</a> \
            sent to the board".
            prettify
        )
      end
    end
  end
end
