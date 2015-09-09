module GithubIssueHelper
  FactoryGirl.define do
    sequence :github_numbers do |number|
      number
    end
  end

  def stub_issue(options = {})
    OpenStruct.new(default_issue_options.merge(options))
  end

  def stub_closed_issue(options = {})
    stub_issue({ state: 'closed', closed_at: Time.current }.merge(options))
  end

  def stub_pull_request_issue(options = {})
    stub_issue({ pull_request: {} }.merge(options))
  end

  private

  def default_issue_options
    {
      number: FactoryGirl.generate(:github_numbers),
      name: 'test name',
      body: 'test body',
      labels: [],
      assigne: nil,
      state: 'open',
      pull_request: nil,
      comments: 0,
      closed_at: nil,
      created_at: Time.current.beginning_of_day,
      updated_at: Time.current.beginning_of_day
    }
  end
end
