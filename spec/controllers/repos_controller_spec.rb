require 'rails_helper'

RSpec.describe ReposController, :type => :controller do

  describe 'GET index' do
    #TODO: extract next 2 lines code to shared context
    let(:repo) { OpenStruct.new({ id: 1, name: 'foo' }) }
    before { allow_any_instance_of(GithubApi).to receive(:repos).and_return([repo]) }
    it 'returns http success' do
      #TODO: extract next 2 lines code to shared context
      user = create(:user)
      stub_sign_in(user)
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
