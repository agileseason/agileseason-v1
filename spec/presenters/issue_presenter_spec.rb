describe IssuePresenter do
  let(:presenter) { present(:issue, issue) }
  let(:issue) { stub_issue(labels: labels) }
  let(:labels) { [] }

  describe '#labels_html' do
    subject { presenter.labels_html }

    context 'with labels' do
      let(:label_1) { OpenStruct.new(name: 'feature', color: 'fff') }
      let(:label_2) { OpenStruct.new(name: 'bug', color: 'fff') }
      let(:labels) { [label_1, label_2] }

      it { is_expected.to eq '<div class="label" style="background-color:#fff; color:#fff">bug</div><div class="label" style="background-color:#fff; color:#fff">feature</div>' }
    end

    context 'without labels' do
      it { is_expected.to be_empty }
    end
  end

  describe '#color' do
    subject { presenter.color(label) }
    let(:label) { OpenStruct.new(name: 'bug', color: color) }
    let(:labels) { [label] }

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

  describe '#title' do
    let(:issue) { OpenStruct.new(title: title) }

    context 'with ABBR' do
      let(:title) { 'some title with ABBR ect' }
      subject { presenter.title }

      it { is_expected.to eq 'Some title with ABBR ect' }
    end
  end
end
