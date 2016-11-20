module IssueJsonRenderer
  extend ActiveSupport::Concern

  included do
    helper_method :number, :number?
  end

  def render_board_issue_json
    board_issue = @board_bag.issue(number)
    render json: {
      number: number,
      issue: render_to_string(
        partial: 'issues/issue_miniature',
        locals: { issue: board_issue },
        formats: [:html]
      )
    }
  end

  def number
    params[:number].to_i
  end

  def number?
    params[:number].present?
  end
end
