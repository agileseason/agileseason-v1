describe RepoListPrivateItem do
  let(:list_item) { RepoListPrivateItem.new(repo, board) }
  let(:repo) { stub_repo }
  let(:board) { build(:board) }

  describe '#icon' do
    subject { list_item.icon }
    it { is_expected.to eq 'octicon-lock' }
  end

  describe '#price' do
    subject { list_item.price }
    it { is_expected.to eq 'Private - $4' }
  end
end
