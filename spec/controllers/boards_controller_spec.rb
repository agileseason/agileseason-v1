require 'rails_helper'

RSpec.describe BoardsController, type: :controller do

  describe "GET new" do
    let(:repo) { OpenStruct.new(id: 1, name: "foo") }
    before { allow_any_instance_of(GithubApi).to receive(:repos).and_return([repo]) }
    before { stub_sign_in }

    it "returns http success" do
      get :new, github_id: repo.id
      expect(response).to have_http_status(:success)
    end
  end
end
