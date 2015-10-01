class GithubApi
  module Repos
    EXPIRES_IN_REPOS = 1.day

    def repos
      fetch_repos = user_repos
      Rails.cache.write(cache_key, fetch_repos, expires_in: EXPIRES_IN_REPOS)
      fetch_repos
    end

    def cached_repos
      Rails.cache.fetch(cache_key, expires_in: EXPIRES_IN_REPOS) { repos }
    end

    def repo(repo_name)
      client.repository(repo_name)
    end

    def collaborators(board)
      client.collaborators(board.github_id)
    end

    private

    def user_repos
      paginate { |page| client.repos(nil, page: page) }
    end

    def cache_key
      [@token, :repos]
    end
  end
end
