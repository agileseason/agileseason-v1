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

      it { is_expected.to eq '<div class="b-issue-labels"><div class="label" style="background-color:#fff; color:#fff; border: 1px solid #fff">bug</div><div class="label" style="background-color:#fff; color:#fff; border: 1px solid #fff">feature</div></div>' }
    end

    context 'without labels' do
      it { is_expected.to eq '<div class="b-issue-labels"></div>' }
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
