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

    "<a href='#{issue_url}' class='issue-url'>issue&nbsp;##{issue_stat.number}</a>"
  end
end
