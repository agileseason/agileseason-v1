describe IssuePresenter do
  let(:presenter) { present(:issue, issue) }
  let(:issue) { stub_issue(labels: labels) }
  let(:label_1) { OpenStruct.new(name: 'feature', color: 'fff') }
  let(:label_2) { OpenStruct.new(name: 'bug', color: 'fff') }
  let(:labels) { [] }

  describe '#labels_html' do
    subject { presenter.labels_html }

    context 'with labels' do
      let(:labels) { [label_1, label_2] }
      it { is_expected.to eq '<div class="b-issue-labels"><div class="label" style="background-color:#fff; color:#fff; border: 1px solid #fff">bug</div><div class="label" style="background-color:#fff; color:#fff; border: 1px solid #fff">feature</div></div>' }
    end

    context 'without labels' do
      it { is_expected.to eq '<div class="b-issue-labels"></div>' }
    end
  end

  describe '#labels_edit_html' do
    subject { presenter.labels_edit_html(board_bag) }
    let(:board) { build_stubbed(:board) }
    let(:board_bag) { BoardBag.new(nil, board) }
    before do
      allow(board_bag).to receive(:labels).and_return([label_1, label_2])
    end

    context 'with labels' do
      let(:labels) { [label_1, label_2] }
      it { is_expected.not_to eq '' }
    end

    context 'without labels' do
      let(:labels) { nil }
      it { is_expected.not_to eq '' }
    end
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
