describe ApplicationHelper do
  describe '.markdown' do
    subject { helper.markdown(text, repo_url) }
    let(:repo_url) { 'http://github.com/a/b' }

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
      it { is_expected.to eq "<p><a href='#{repo_url}/issues/#{number}' target='_blank'>##{number}</a></p>\n" }
    end

    context 'with #abs' do
      let(:text) { '#abs' }
      it { is_expected.to eq "<h1>abs</h1>\n" }
    end

    context 'with ##abs' do
      let(:text) { '##abs' }
      it { is_expected.to eq "<h2>abs</h2>\n" }
    end

    context 'with two numbers' do
      let(:text) { "text ##{number_1}\n text2 ##{number_2}" }
      let(:number_1) { 10 }
      let(:number_2) { 999 }
      it { is_expected.to eq "<p>text <a href='#{repo_url}/issues/#{number_1}' target='_blank'>##{number_1}</a>\n text2 <a href='http://github.com/a/b/issues/#{number_2}' target='_blank'>##{number_2}</a></p>\n" }
    end
  end
end
