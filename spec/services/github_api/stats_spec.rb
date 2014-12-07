require 'rails_helper'

RSpec.describe GithubApi::Stats do
  let(:service) { GithubApi.new('github_token_example') }

  describe '.repo_lines' do
    subject { service.repo_lines(board) }
    let(:board) { build(:board) }
    before { allow_any_instance_of(Octokit::Client).to receive(:code_frequency_stats).and_return(code_frequency_stats) }

    context :no_stats do
      let(:code_frequency_stats) { "" }
      it { is_expected.to be_zero }
    end

    context :with_stats do
      let(:code_frequency_stats) { [[1414886400, 57, 0], [1415491200, 2971, -176], [1416096000, 229, -76], [1416700800, 1025, -997], [1417305600, 287, -68]] }
      it { is_expected.to eq 3252 }
    end
  end
end
