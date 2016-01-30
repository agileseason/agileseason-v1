module GithubUserHelper
  FactoryGirl.define do
    sequence :github_user_ids do |id|
      id
    end
  end

  def stub_user(options = {})
    OpenStruct.new(default_user_options.merge(options))
  end

  def default_user_options
    id = FactoryGirl.generate(:github_user_ids)
    {
      id: id,
      login: "user#{id}",
      avatar_url: "https://test.ru/avatar/user#{id}"
    }
  end
end
