class GithubApi
  module Repos
    def repos
      user_repos + org_repos
    end

    def cached_repos
      Rails.cache.fetch([@token, :repos], expires_in: 5.minutes) { repos }
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
        paginate { |page| client.org_repos(org[:login], page: page).select { |repo| repo.permissions.push } }
      end
    end

    def orgs
      client.orgs
    end
  end
end
