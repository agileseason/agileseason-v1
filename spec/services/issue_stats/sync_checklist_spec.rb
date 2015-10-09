describe IssueStats::SyncChecklist do
  let(:issue_stat) do
    create(
      :issue_stat,
      number: 1,
      checklist: 2,
      checklist_progress: 1
    )
  end

  describe '.call' do
    subject do
      IssueStats::SyncChecklist.call(
        issue_stat: issue_stat,
        comments: comments
      )
    end

    context 'no comment' do
      let(:comments) { [] }

      its(:checklist) { is_expected.to be_nil }
      its(:checklist_progress) { is_expected.to be_nil }
    end

    context 'with comment without checkboxes' do
      let(:comments) { [comment_1, comment_2] }
      let(:comment_1) { double(body: 'test comment 1') }
      let(:comment_2) { double(body: 'test comment 2') }

      its(:checklist) { is_expected.to be_nil }
      its(:checklist_progress) { is_expected.to be_nil }
    end

    context 'with comment with checkboxes' do
      let(:comments) { [comment_1, comment_2] }
      let(:comment_1) { double(body: 'test comment 1') }
      let(:comment_2) { double(body: body) }
      let(:body) do
<<MARKDOWN
Checkbox header

- [ ] ch1
- [x] ch2
- [x] ch3
- [ ] ch4
- [ ] ch5

footer
MARKDOWN
      end

      its(:checklist) { is_expected.to eq 5 }
      its(:checklist_progress) { is_expected.to eq 2 }
    end
  end
end
