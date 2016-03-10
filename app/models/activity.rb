class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :board
  belongs_to :issue_stat

  serialize :data

  validates :user, presence: true

  self.per_page = 20

  def description(issue_url = nil)
  end

  private

  def link_to(issue_url)
    return if issue_url.blank?

    "<a href='#' class='issue-ajax' \
      data-number='#{issue_stat.number}' \
      data-url='#{issue_url}'>issue&nbsp;##{issue_stat.number}</a>"
  end
end
