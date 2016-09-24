describe DocsController do
  describe '#main' do
    subject { get :main }
    it { is_expected.to redirect_to(board_features_docs_url) }
  end
end
