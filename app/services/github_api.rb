require 'octokit'
require 'base64'
require 'active_support/core_ext/object/with_options'

class GithubApi
  include GithubApi::Comments
  include GithubApi::Hooks
  include GithubApi::Issues
  include GithubApi::Labels
  include GithubApi::Repos
  include GithubApi::Stats

  SERVICES_TEAM_NAME = 'Services'

  def initialize(token, user = nil)
    @token = token
    @user = user
  end

  def client
    @client ||= Octokit::Client.new(access_token: @token, auto_paginate: true)
  end

  def github_token
    @token
  end

  private

  def admin_access_team(repo_teams)
    token_bearer = GithubUser.new(self)

    repo_teams.detect do |repo_team|
      token_bearer.has_admin_access_through_team?(repo_team.id)
    end
  end

  def paginate
    page = 1
    results = []
    all_pages_fetched = false

    until all_pages_fetched do
      page_results = yield(page)

      if page_results.empty?
        all_pages_fetched = true
      else
        results += page_results
        page += 1
      end
    end

    results
  end
end
