describe ApplicationHelper do
  describe '.github_avatar_url' do
    subject { helper.github_avatar_url(user) }
    let(:user) { build(:user, github_username: 'test-x') }

    it { is_expected.to eq 'https://avatars.githubusercontent.com/test-x' }
  end

  describe '.markdown' do
    subject { helper.markdown(text, board) }
    let(:board) { build_stubbed(:board) }

    context 'check numbers' do
      context 'blank' do
        let(:text) {}
        it { is_expected.to be_nil }
      end

      context 'empty' do
        let(:text) { '' }
        it { is_expected.to eq '' }
      end

      context 'simple text' do
        let(:text) { 'text' }
        it { is_expected.to eq "<p>text</p>\n" }
      end

      context 'with #number' do
        let(:text) { "##{number}" }
        let(:number) { 10 }

        it do
          is_expected.
            to eq(
              "<p><a href='#{un show_board_issues_url(board, number)}'>##{number}</a></p>\n"
            )
        end
      end

      context 'with #abs' do
        let(:text) { '#abs' }
        it { is_expected.to eq "<p>#abs</p>\n" }
      end

      context 'with ##abs' do
        let(:text) { '##abs' }
        it { is_expected.to eq "<p>##abs</p>\n" }
      end

      context 'with two numbers' do
        let(:text) { "text ##{number_1} text2 ##{number_2}" }
        let(:number_1) { 10 }
        let(:number_2) { 999 }

        it do
          is_expected.
            to eq(
              "<p>text <a href='#{un show_board_issues_url(board, number_1)}'>##{number_1}</a> " +
              "text2 <a href='#{un show_board_issues_url(board, number_2)}'>##{number_2}</a></p>\n"
            )
        end
      end
    end

    context 'check header' do
      context 'not header' do
        let(:text) { '#abs' }
        it { is_expected.to eq "<p>#abs</p>\n" }
      end

      context 'header' do
        let(:text) { '# abs' }
        it { is_expected.to eq "<h1>abs</h1>\n" }
      end
    end

    context 'links' do
      let(:text) { 'http://agileseason.com' }
      it { is_expected.to eq "<p><a href=\"#{text}\">#{text}</a></p>\n" }
    end

    context 'checkboxes' do
      context 'one - unchecked' do
        let(:text) { '- [ ] ch1' }
        it { is_expected.to eq "<p><input type=\"checkbox\" class=\"task\" />ch1</p>\n" }
      end

      context 'one - checked' do
        let(:text) { '- [x] ch1' }
        it { is_expected.to eq "<p><input type=\"checkbox\" class=\"task\" checked />ch1</p>\n" }
      end

      context 'complex' do
        let(:text) do
<<-TEXT
- [ ] ch1
- [x] ch2

text
- [ ] ch3
TEXT
        end
        let(:expected_text) do
<<-HTML
<p><input type=\"checkbox\" class=\"task\" />ch1<br>\n<input type=\"checkbox\" class=\"task\" checked />ch2</p>\n\n<p>text<br>\n<input type=\"checkbox\" class=\"task\" />ch3</p>
HTML
        end
        it { is_expected.to eq expected_text }
      end
    end
  end
end
