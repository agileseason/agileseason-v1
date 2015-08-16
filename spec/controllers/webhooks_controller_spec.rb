require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do

  describe "GET #github" do
    it "returns http success" do
      get :github
      expect(response).to have_http_status(:success)
    end
  end

end
