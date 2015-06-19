describe Encryptor do
  describe '.encrypt' do
    subject { Encryptor.encrypt(arg) }
    let(:arg) { 'asdf' }
    it { is_expected.to_not eq arg }
  end
end
