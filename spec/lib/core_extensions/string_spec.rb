describe String do
  describe 'upcase' do
    context 'russian' do
      it { expect('Русский Текст'.upcase).to eq 'РУССКИЙ ТЕКСТ' }
    end

    context 'english' do
      it { expect('english Text'.upcase).to eq 'ENGLISH TEXT' }
    end
  end

  describe 'downcase' do
    context 'russian' do
      it { expect('Русский Текст'.downcase).to eq 'русский текст' }
    end

    context 'english' do
      it { expect('English Text'.downcase).to eq 'english text' }
    end
  end

  describe 'capitalize' do
    context 'russian' do
      it { expect('русский текст'.capitalize).to eq 'Русский текст' }
    end

    context 'english' do
      it { expect('english text'.capitalize).to eq 'English text' }
    end
  end

  describe 'uncapitalize' do
    context 'russian' do
      it { expect('Русский Текст'.uncapitalize).to eq 'русский Текст' }
    end

    context 'english' do
      it { expect('English Text'.uncapitalize).to eq 'english Text' }
    end
  end

  describe '#with_http' do
    subject { string.with_http }

    context 'has_http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq 'http://test.org' }
    end

    context 'no_http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq 'http://test.org' }
    end
  end

  describe 'without_http' do
    subject { string.without_http }

    context 'has_http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq 'test.org' }
    end

    context 'no_http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq 'test.org' }
    end
  end

  describe '#extract_domain' do
    subject { url.extract_domain }

    context 'with_www' do
      let(:url) { "http://www.test.org/test" }
      it { is_expected.to eq 'www.test.org' }
    end

    context 'without_www' do
      let(:url) { "http://test.org/test" }
      it { is_expected.to eq 'test.org' }
    end
  end

  describe '#extract_path' do
    subject { "http://www.test.org/test/test".extract_path }
    it { is_expected.to eq '/test/test' }
  end

  describe '#prettify' do
    it { expect(" test  test\ntest\r\n test ".prettify).to eq 'test test test test' }
  end

  describe '#punycode' do
    subject { string.punycode }

    context 'punycoded' do
      let(:string) { 'http://xn--80aedbwe4a.xn----7sbah3bd2a2j.xn--p1ai/test' }
      it { is_expected.to eq 'http://xn--80aedbwe4a.xn----7sbah3bd2a2j.xn--p1ai/test' }
    end

    context 'url_with_port' do
      let(:string) { 'http://овд-арзамас.рф:8080' }
      it { is_expected.to eq 'http://xn----8sbaagmx5blyp.xn--p1ai:8080' }
    end

    context 'russian_url' do
      let(:string) { 'http://дайвинг.аква-эко.рф/test' }
      it { is_expected.to eq 'http://xn--80aedbwe4a.xn----7sbah3bd2a2j.xn--p1ai/test' }
    end

    context 'normal_url' do
      let(:string) { 'http://test.ru/test' }
      it { is_expected.to eq 'http://test.ru/test' }
    end
  end

  describe '#depunycode' do
    subject { string.depunycode }

    context 'punycoded' do
      let(:string) { 'http://xn--80aedbwe4a.xn----7sbah3bd2a2j.xn--p1ai/test' }
      it { is_expected.to eq 'http://дайвинг.аква-эко.рф/test' }
    end

    context 'punycoded with dot' do
      let(:string) { "http://xn----htbyhhgt.xn--p1ai/effektivnyy-sayt-kompanii." }
      it { is_expected.to eq "http://фрс-дом.рф/effektivnyy-sayt-kompanii." }
    end

    context 'punycoded with port' do
      let(:string) { "xn----8sbaagmx5blyp.xn--p1ai:8080" }
      it { is_expected.to eq "овд-арзамас.рф:8080" }
    end

    context 'russian url' do
      let(:string) { 'http://дайвинг.аква-эко.рф/test' }
      it { is_expected.to eq 'http://дайвинг.аква-эко.рф/test' }
    end

    context 'normal url' do
      let(:string) { 'http://test.ru/test' }
      it { is_expected.to eq 'http://test.ru/test' }
    end

    context 'root url' do
      let(:string) { 'http://test.ru/' }
      it { is_expected.to eq 'http://test.ru/' }
    end

    context 'raw domain' do
      let(:string) { "zxc.ru" }
      it { is_expected.to eq "zxc.ru" }
    end

    context 'malformed punycode' do
      let(:string) { "http://xn--80amkfe6bh3.ucoz.ru/" }
      it { is_expected.to eq string }
    end
  end

  describe '#has_protocol?' do
    subject { string.has_protocol? }

    context 'no protocol' do
      let(:string) { 'test.ru' }
      it { is_expected.to eq false }
    end

    context 'http' do
      let(:string) { 'http://test.ru' }
      it { is_expected.to eq true }
    end

    context 'https' do
      let(:string) { 'https://test.ru' }
      it { is_expected.to eq true }
    end
  end
end
