require 'rails_helper'

RSpec.describe IssuesController, :type => :controller do

  describe 'GET new' do
    let!(:board) { create :board_with_columns }
    it 'returns http success' do
      #get :new, { board_id: board.id }
      #expect(response).to have_http_status(:success)
    end
  end

end
