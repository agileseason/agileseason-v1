class GithubApi
  module Repos
    def repos
      fetch_repos = user_repos + org_repos
      Rails.cache.write(cache_key, fetch_repos, expires_in: 1.month)
      fetch_repos
    end

    def cached_repos
      Rails.cache.fetch(cache_key, expires_in: 1.month) { repos }
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

    def org_repos
      orgs.flat_map do |org|
        paginate do |page|
          client.
            org_repos(org[:login], page: page).
            select { |repo| repo.permissions.push }
        end
      end
    end

    def orgs
      client.orgs
    end

    def cache_key
      [@token, :repos]
    end
  end
end
