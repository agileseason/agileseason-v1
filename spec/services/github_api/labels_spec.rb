describe GithubApi::Labels do
  let(:service) { GithubApi.new('fake_github_token') }
  let(:board) { build(:board, columns: [column_1, column_2]) }
  let(:column_1) { build(:column, name: 'backlog', order: 1) }
  let(:column_2) { build(:column, name: 'todo', order: 2) }
  let(:labels) { [label_1, label_2, label_3] }
  let(:label_1) { OpenStruct.new(name: '[1] backlog') }
  let(:label_2) { OpenStruct.new(name: 'feature') }
  let(:label_3) { OpenStruct.new(name: 'bug') }
  before { allow_any_instance_of(Octokit::Client).to receive(:labels).and_return(labels) }

  describe '.labels' do
    subject { service.labels(board) }

    it { is_expected.to have(3).item }
    it { is_expected.to eq labels.sort_by(&:name) }
  end
end
