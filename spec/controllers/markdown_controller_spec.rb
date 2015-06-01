RSpec.describe MarkdownController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }

  describe '#preview' do
    before { post :preview, board_github_full_name: board.github_full_name, string: 'text' }

    it 'return http success' do
      expect(response).to be_successful
      expect(response.body).to eq "<p>text</p>\n"
    end
  end
end
