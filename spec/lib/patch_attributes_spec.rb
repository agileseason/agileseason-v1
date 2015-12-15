describe PatchAttributes do
  class FakeController
    include PatchAttributes

    def fetch_resource
      Board.find params[:id]
    end

    def render_result
      'fake-view'
    end

    def params
    end
  end

  describe '#update_attribute' do
    subject { controller.update_attribute }
    let(:controller) { FakeController.new }
    let(:params) { { id: board.id, name: 'name', value: 'new-name' } }
    let(:board) { create :board, :with_columns }
    before { allow(controller).to receive(:params).and_return params }
    before { subject }

    it { expect(board.reload.name).to eq 'new-name' }
    it { is_expected.to eq 'fake-view' }
  end
end
