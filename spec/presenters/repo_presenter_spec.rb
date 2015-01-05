describe RepoPresenter do
  let(:presenter) { present(:repo, repo) }

  describe '#board_control?' do
    let(:repo) { OpenStruct.new(permissions: permissions) }
    let(:permissions) { OpenStruct.new(admin: is_admin) }
    subject { presenter.board_control? }

    context :true do
      let(:is_admin) { true }
      it { is_expected.to eq true }
    end

    context :false do
      let(:is_admin) { false }
      it { is_expected.to eq false }
    end
  end

  describe '#board' do
    let(:repo) { OpenStruct.new(id: 123) }
    subject { presenter.board }

    context :not_exist do
      it { is_expected.to be_nil }
    end

    context :exist do
      let!(:board) { create(:board, :with_columns, github_id: repo.id) }
      it { is_expected.to_not be_nil }
      it { expect(subject.id).to eq board.id }
    end
  end
end
