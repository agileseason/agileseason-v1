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

  def add_user_to_repo(username, repo_name)
    repo = repo(repo_name)

    if repo.organization
      add_user_to_org(username, repo)
    else
      client.add_collaborator(repo.full_name, username)
    end
  end

  def create_hook(full_repo_name, callback_endpoint)
    hook = client.create_hook(
      full_repo_name,
      'web',
      { url: callback_endpoint },
      { events: ['pull_request'], active: true }
    )

    if block_given?
      yield hook
    else
      hook
    end
  rescue Octokit::UnprocessableEntity => error
    if error.message.include? 'Hook already exists'
      true
    else
      raise
    end
  end

  def remove_hook(full_github_name, hook_id)
    response = client.remove_hook(full_github_name, hook_id)

    if block_given?
      yield
    else
      response
    end
  end

  def pull_request_comments(full_repo_name, pull_request_number)
    paginate do |page|
      client.pull_request_comments(
        full_repo_name,
        pull_request_number,
        page: page
      )
    end
  end

  def pull_request_files(full_repo_name, number)
    client.pull_request_files(full_repo_name, number)
  end

  def file_contents(full_repo_name, filename, sha)
    client.contents(full_repo_name, path: filename, ref: sha)
  end

  def user_teams
    client.user_teams
  end

  private

  def add_user_to_org(username, repo)
    repo_teams = client.repository_teams(repo.full_name)
    admin_team = admin_access_team(repo_teams)

    if admin_team
      add_user_to_team(username, admin_team.id)
    else
      add_user_and_repo_to_services_team(username, repo)
    end
  end

  def admin_access_team(repo_teams)
    token_bearer = GithubUser.new(self)

    repo_teams.detect do |repo_team|
      token_bearer.has_admin_access_through_team?(repo_team.id)
    end
  end

  def add_user_and_repo_to_services_team(username, repo)
    team = find_team(SERVICES_TEAM_NAME, repo)

    if team
      client.add_team_repository(team.id, repo.full_name)
    else
      team = create_team(SERVICES_TEAM_NAME, repo)
    end

    add_user_to_team(username, team.id)
  end

  def add_user_to_team(username, team_id)
    with_preview_client do |preview_client|
      preview_client.add_team_membership(team_id, username)
    end
  rescue Octokit::NotFound
    false
  end

  def find_team(name, repo)
    client.org_teams(repo.organization.login).detect do |team|
      team.name.downcase == name.downcase
    end
  end

  def create_team(name, repo)
    team_options = {
      name: name,
      repo_names: [repo.full_name],
      permission: 'pull'
    }
    client.create_team(repo.organization.login, team_options)
  rescue Octokit::UnprocessableEntity => e
    if team_exists_exception?(e)
      find_team(name, repo)
    else
      raise
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

  def team_exists_exception?(exception)
    exception.errors.any? do |error|
      error[:field] == 'name' && error[:code] == 'already_exists'
    end
  end

end
