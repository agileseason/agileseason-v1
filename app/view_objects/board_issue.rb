class BoardIssue
  attr_accessor :issue, :issue_stat

  def initialize(issue, issue_stat)
    @issue = issue
    @issue_stat = issue_stat
  end
end
