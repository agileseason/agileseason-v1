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

    private

    def user_repos
      repos = paginate { |page| client.repos(nil, page: page) }
      authorized_repos(repos)
    end

    def org_repos
      repos = orgs.flat_map do |org|
        paginate { |page| client.org_repos(org[:login], page: page) }
      end

      authorized_repos(repos)
    end

    def authorized_repos(repos)
      repos.select { |repo| repo.permissions.admin }
    end

    def orgs
      client.orgs
    end
  end
end
