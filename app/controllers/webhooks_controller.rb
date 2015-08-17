class WebhooksController < ApplicationController
  skip_before_filter :authenticate
  skip_before_filter :verify_authenticity_token

  HMAC_DIGEST = OpenSSL::Digest::Digest.new('sha1')

  def github
    # TODO Remove webhook if board delete or user sigin in long time ago.
    if trusted_request? && board.present?
      # TODO Fix dublicate last issue on board if creating via github.
      board_bag.update_cache(issue)
    end
    render nothing: true
  end

  private

  def issue
    @issue ||= begin
      issue = OpenStruct.new(params[:issue])
      issue.labels = issue.labels.map { |label| OpenStruct.new(label) } if issue.labels.present?
      issue.assignee = OpenStruct.new(issue.assignee) if issue.assignee.present?
      issue.created_at = Time.parse(issue.created_at)
      issue.updated_at = Time.parse(issue.updated_at)
      issue
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
    @secret ||= Rails.application.secrets.secret_key_base.first(20)
  end
end