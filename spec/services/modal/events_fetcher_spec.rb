describe Modal::EventsFetcher do
  subject do
    Modal::EventsFetcher.call(
      user: user,
      board_bag: board_bag,
      number: 1
    )
  end
  let(:user) { build :user }
  let(:board_bag) { double(issue: board_issue, board: nil) }
  let(:board_issue) { double(issue: issue) }
  let(:github_user) do
    OpenStruct.new(
      id: 1001,
      login: 'foo',
      avatar_url: 'http://foo/img.jpg'
    )
  end

  context 'without issue' do
    let(:issue) { nil }
    it { is_expected.to be_empty }
  end

  context 'with open issue' do
    let(:issue) { stub_issue(user: github_user) }
    it { is_expected.to have(1).item }
  end

  context 'with open closed' do
    let(:issue) { stub_issue(user: github_user, state: 'closed') }
    let(:github_events) do
      [
        OpenStruct.new(
          id: 1,
          actor: github_user,
          created_at: Time.current
        )
      ]
    end
    before { allow(Cached::Events).to receive(:call).and_return(github_events) }

    it { is_expected.to have(2).item }
  end
end
