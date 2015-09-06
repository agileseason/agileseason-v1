module GithubRepoHelper
  FactoryGirl.define do
    sequence :github_repo_ids do |number|
      number
    end
  end

  def stub_repo(options = {})
    OpenStruct.new(default_repo_options.merge(options))
  end

  private

  def default_repo_options
    {
      number: FactoryGirl.generate(:github_repo_ids),
      name: 'repo-test-name',
      full_name: 'repo-test/repo-test-name',
      html_url: 'https://github.com/repo-test/repo-test-name',
      permissions: default_repo_permissions,
      private: false
    }
  end

  def default_repo_permissions
    OpenStruct.new(admin: true)
  end
end
