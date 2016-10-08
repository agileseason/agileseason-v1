describe Activities::ChangeDueDate, type: :model do
  describe '.create_for' do
    subject { Activities::ChangeDueDate.create_for(issue_stat, user) }
    let(:user) { build(:user) }
    let(:board) { build(:board_with_columns, user: user) }
    let(:issue_stat) { build(:issue_stat, board: board, due_date_at: due_date_at) }
    let(:due_date_at) { DateTime.now }

    it { expect { subject }.to change(Activities::ChangeDueDate, :count).by(1) }
    its(:board) { is_expected.to eq board }
    its(:issue_stat) { is_expected.to eq issue_stat }
    its(:data) { is_expected.to eq(due_date_at: due_date_at) }
  end

  describe '#description' do
    subject { activity.description(issue_link).gsub(/\s+/, ' ') }
    let(:issue_link) { 'test/123' }
    let(:issue_stat) { build(:issue_stat) }
    let(:activity) do
      create(
        :change_due_date_acivity,
        issue_stat: issue_stat,
        data: data
      )
    end
    let(:data) { { due_date_at: due_date_at } }

    context 'with due date' do
      let(:due_date_at) { DateTime.now }
      it do
        is_expected.to eq(
          "changed due date for <a href='#' class='issue-ajax' \
            data-number='#{issue_stat.number}' \
            data-turbolinks='false' \
            data-url='#{issue_link}'>issue&nbsp;##{issue_stat.number}</a> \
            on #{due_date_at.strftime('%b %d %H:%M')}".
            prettify
        )
      end
    end

    context 'without due date' do
      let(:due_date_at) { nil }
      it do
        is_expected.to eq(
          "removed due date for <a href='#' class='issue-ajax' \
          data-number='#{issue_stat.number}' \
          data-turbolinks='false' \
          data-url='#{issue_link}'>issue&nbsp;##{issue_stat.number}</a>".
          prettify
        )
      end
    end

    context 'without data' do
      let(:data) { nil }
      it do
        is_expected.to eq(
          "removed due date for <a href='#' class='issue-ajax' \
          data-number='#{issue_stat.number}' \
          data-turbolinks='false' \
          data-url='#{issue_link}'>issue&nbsp;##{issue_stat.number}</a>".
          prettify
        )
      end
    end
  end
end
