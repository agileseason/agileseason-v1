class WebhooksController < ApplicationController
  include Broadcaster

  skip_authorization_check
  skip_before_action :verify_authenticity_token

  HMAC_DIGEST = OpenSSL::Digest.new('sha1')

  def github
    if issue_present? && trusted_request? && board.present?
      update_cache_issues
      issue_stat = IssueStatService.find(board_bag, issue.number)
      # NOTE Broadcast event from GuesUser with client_id: guest_token
      broadcast_column(issue_stat.column) if issue_stat.present?
    end

    head :ok
  end

  private

  def issue_present?
    params[:issue].present?
  end

  def issue
    @issue ||= begin
      issue = OpenStruct.new(params[:issue])
      issue.number = issue.number.to_i
      issue.comments = issue.comments.to_i
      issue.labels = issue.labels.map { |label| OpenStruct.new(label) } if issue.labels.present?
      issue.assignee = OpenStruct.new(issue.assignee) if issue.assignee.present?
      issue.created_at = Time.parse(issue.created_at)
      issue.updated_at = Time.parse(issue.updated_at)
      issue
    end
  end

  def update_cache_issues
    issues_hash = Cached::ReadIssues.call(board: board)
    unless issues_hash.nil?
      issues_hash[issue.number.to_i] = issue
      Cached::UpdateIssues.call(board: board, objects: issues_hash)
    end
  end

  def repo
    @repo ||= OpenStruct.new(params[:repository])
  end

  def board
    @board ||= Board.find_by(github_full_name: repo.full_name)
  end

  def board_bag
    @board_bag ||= BoardBag.new(nil, board)
  end

  def trusted_request?
    hash_sum = OpenSSL::HMAC.hexdigest(HMAC_DIGEST, secret, request.body.read)
    "sha1=#{hash_sum}" == request.headers['X-Hub-Signature']
  end

  def secret
    # NOTE Secret is not displayed in Github interface.
    @secret ||= Rails.application.secrets.secret_key_base.first(20)
  end
end
