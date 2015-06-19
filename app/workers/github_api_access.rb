module GithubApiAccess
  def github_api(encrypted_github_token)
    GithubApi.new(Encryptor.decrypt(encrypted_github_token))
  end
end
