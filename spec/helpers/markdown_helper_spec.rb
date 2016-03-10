describe MarkdownHelper do
  describe '.markdown' do
    subject { markdown.gsub(/\s+/, ' ').strip }
    let(:markdown) { helper.markdown(text, board) }
    let(:board) { build_stubbed(:board) }

    context 'check numbers' do
      context 'blank' do
        subject { markdown }
        let(:text) {}
        it { is_expected.to be_nil }
      end

      context 'empty' do
        let(:text) { '' }
        it { is_expected.to eq '' }
      end

      context 'simple text' do
        let(:text) { 'text' }
        it { is_expected.to eq '<p>text</p>' }
      end

      context 'with #number' do
        let(:text) { "##{number}" }
        let(:number) { 10 }

        it do
          is_expected.
            to eq(
              "<p><a class='issue-ajax' \
                href='#' data-number='#{number}' \
                data-url='#{un UrlGenerator.modal_data_board_issues_url(board, number)}'>##{number}</a></p>".gsub(/\s+/, ' ')
            )
        end
      end

      context 'with #abs' do
        let(:text) { '#abs' }
        it { is_expected.to eq '<p>#abs</p>' }
      end

      context 'with ##abs' do
        let(:text) { '##abs' }
        it { is_expected.to eq '<p>##abs</p>' }
      end

      context 'with two numbers' do
        let(:text) { "text ##{number_1} text2 ##{number_2}" }
        let(:number_1) { 10 }
        let(:number_2) { 999 }

        it do
          is_expected.
            to eq(
              "<p>text <a class='issue-ajax' \
                href='#' data-number='#{number_1}' \
                data-url='#{un UrlGenerator.modal_data_board_issues_url(board, number_1)}'>##{number_1}</a> \
                text2 <a class='issue-ajax' \
                href='#' data-number='#{number_2}' \
                data-url='#{un UrlGenerator.modal_data_board_issues_url(board, number_2)}'>##{number_2}</a></p>".
                gsub(/\s+/, ' ')
            )
        end
      end
    end

    context 'check header' do
      context 'not header' do
        let(:text) { '#abs' }
        it { is_expected.to eq "<p>#abs</p>" }
      end

      context 'header' do
        let(:text) { '# abs' }
        it { is_expected.to eq "<h1>abs</h1>" }
      end
    end

    context 'links' do
      let(:text) { 'http://agileseason.com' }
      it { is_expected.to eq "<p><a href=\"#{text}\">#{text}</a></p>" }
    end

    context 'checkboxes' do
      context 'one - unchecked' do
        let(:text) { '- [ ] ch1' }
        it do
          is_expected.
            to eq '<p><input type=\"checkbox\" class=\"task\" />ch1</p>'
        end
      end

      context 'one - checked' do
        let(:text) { '- [x] ch1' }
        it do
          is_expected.
            to eq '<p><input type=\"checkbox\" class=\"task\" checked />ch1</p>'
        end
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
          "<p><input type=\"checkbox\" class=\"task\" />ch1<br> \
          <input type=\"checkbox\" class=\"task\" checked />ch2</p> <p>text<br> \
          <input type=\"checkbox\" class=\"task\" />ch3</p>".
          gsub(/\s+/, ' ')
        end
        it { is_expected.to eq expected_text }
      end
    end
  end
end
