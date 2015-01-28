describe IssuePresenter do
  let(:presenter) { present(:issue, issue) }
  let(:issue) { OpenStruct.new(labels: [label]) }
  let(:label) { OpenStruct.new(name: 'bug', color: color) }

  describe '#color' do
    subject { presenter.color(label) }

    context 'red' do
      let(:color) { 'fc2929' }
      it { is_expected.to eq 'fff' }
    end

    context 'white' do
      let(:color) { 'ffffff' }
      it { is_expected.to eq '000' }
    end

    context 'dark blue' do
      let(:color) { '5319e7' }
      it { is_expected.to eq 'fff' }
    end

    context 'blue' do
      let(:color) { '84b6eb' }
      it { is_expected.to eq '000' }
    end
  end

  describe '#archived?' do
    let(:issue) { OpenStruct.new(number: 1) }
    let(:board) { build(:board) }
    subject { presenter.archived?(board) }
    before { allow(IssueStatService).to receive(:archived?) }
    after { subject }

    it { expect(IssueStatService).to receive(:archived?).with(board, issue.number) }
  end

  describe '#display_labels' do
    subject { presenter.display_labels(board) }
    let(:board) { build(:board, :with_columns) }
    let(:issue) { OpenStruct.new(labels: [label_1, label_2]) }
    let(:label_1) { OpenStruct.new(name: board.columns.first.label_name) }
    let(:label_2) { OpenStruct.new(name: 'feature') }

    it { is_expected.to eq [label_2] }
  end

  describe '#body_empty?' do
    let(:issue) { OpenStruct.new(body: body) }
    subject { presenter.body_empty? }

    context 'true with whitespace' do
      let(:body) { "  \n<!---\n@agileseason:{}\n-->" }
      it { is_expected.to eq true }
    end

    context :true do
      let(:body) { "<!---\n@agileseason:{}\n-->" }
      it { is_expected.to eq true }
    end

    context :false do
      let(:body) { "Some description \n<!---\n@agileseason:{}\n-->" }
      it { is_expected.to eq false }
    end
  end
end
