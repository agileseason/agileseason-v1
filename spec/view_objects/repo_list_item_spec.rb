describe RepoListItem do
  let(:list_item) { RepoListItem.new(repo, board) }
  let(:repo) { stub_repo }
  let(:board) { build(:board) }

  describe '#url' do
    subject { list_item.url }
    it { is_expected.to eq repo.html_url }
  end

  describe '#name' do
    subject { list_item.name }
    it { is_expected.to eq repo.full_name }
  end

  describe '#icon' do
    subject { list_item.icon }
    it { is_expected.to eq 'octicon-repo' }
  end

  describe '#can_create_board?' do
    subject { list_item.can_create_board? }
    let(:repo) { stub_repo(permissions: permissions) }
    let(:permissions) { OpenStruct.new(admin: is_admin) }

    context true do
      let(:is_admin) { true }
      it { is_expected.to eq true }
    end

    context false do
      let(:is_admin) { false }
      it { is_expected.to eq false }
    end
  end

  describe '#price' do
    subject { list_item.price }
    it { is_expected.to be_nil }
  end

  describe '#enough_permissions?' do
    subject { list_item.enough_permissions? }
    let(:repo) { stub_repo(permissions: permissions) }
    let(:permissions) { OpenStruct.new(admin: is_admin) }

    context true do
      context 'has admin right to create' do
        let(:is_admin) { true }
        let(:board) { nil }

        it { is_expected.to eq true }
      end

      context 'no admin right but board already created' do
        let(:is_admin) { false }
        it { is_expected.to eq true }
      end
    end

    context false do
      context 'no baord and no right' do
        let(:board) { nil }
        let(:is_admin) { false }

        it { is_expected.to eq false }
      end
    end
  end
end
