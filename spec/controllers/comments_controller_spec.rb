RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }

  #describe '#index' do
    #subject { get :index, board_github_full_name: board.github_full_name, number: 1 }
    #before { allow_any_instance_of(GithubApi).to receive(:issue_comments).and_return([]) }
    #before { subject }

    #it { expect(response).to have_http_status(:success) }
    #it { expect(response).to render_template(partial: '_index') }
  #end

  describe '#create' do
    subject { post :create, board_github_full_name: board.github_full_name, number: 1 }

    context 'check response' do
      before { allow_any_instance_of(GithubApi).to receive(:add_comment) }
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to be_empty }
    end

    context 'call add_comment in github_api' do
      after { subject }
      it { expect_any_instance_of(GithubApi).to receive(:add_comment) }
    end
  end

  describe '#update' do
    subject { post :update, board_github_full_name: board.github_full_name, number: 1 }

    context 'check response' do
      before { allow_any_instance_of(GithubApi).to receive(:update_comment) }

      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to be_empty }
    end

    context 'call update_comment in github_api' do
      after { subject }
      it { expect_any_instance_of(GithubApi).to receive(:update_comment) }
    end
  end

  describe '#delete' do
    subject { delete :delete, board_github_full_name: board.github_full_name, number: 1 }

    context 'check response' do
      before { allow_any_instance_of(GithubApi).to receive(:delete_comment) }
      before { subject }
      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to be_empty }
    end

    context 'call delete_comment' do
      after { subject }
      it { expect_any_instance_of(GithubApi).to receive(:delete_comment).once }
    end
  end
end
