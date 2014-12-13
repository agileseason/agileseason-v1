require 'rails_helper'

RSpec.describe IssuesController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }

  describe 'GET new' do
    it 'returns http success' do
      get :new, { board_id: board.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET close' do
    before { allow_any_instance_of(GithubApi).to receive(:close) }
    it 'return http success' do
      get :close, { board_id: board.id, number: 1 }
      expect(response).to redirect_to(board_url(board))
    end
  end
end
