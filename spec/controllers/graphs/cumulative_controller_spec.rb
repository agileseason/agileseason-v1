require "rails_helper"

RSpec.describe Graphs::CumulativeController, type: :controller do
  describe "GET index" do
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    it 'returns http success' do
      stub_sign_in(user)
      get :index, board_id: board.id
      expect(response).to have_http_status(:success)
    end
  end
end
