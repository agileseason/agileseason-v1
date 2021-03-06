class IssuePresenter < Keynote::Presenter
  presents :issue
  delegate :labels, :number, to: :issue

  def labels_html
    build_html do
      div(class: 'b-issue-labels') do
        next if labels.blank? # NOTE If statement for exclude '[]' in html.

        labels.sort_by(&:name).each do |label|
          div.label(label.name, style: k(:label, label).css_style)
        end
      end
    end
  end

  def collaborators_to_json(board_bag)
    board_bag.collaborators.map do |user|
      { login: user.login, avatarUrl: user.avatar_url }
    end
  end

  def due_date_at
    issue.due_date_at.try(:utc).try(:strftime, '%b %d %H:%M')
  end

  def due_date_on
    issue.due_date_at.try(:utc).try(:strftime, '%b %d')
  end

  def body_empty?
    issue.body.blank? || issue.body.strip.start_with?('<!---')
  end

  def title
    issue.title.slice(0, 1).capitalize + issue.title.slice(1..-1)
  end

  def to_hash(board_bag)
    issue.to_hash_min.merge(
      labels: labels_to_json(board_bag),
      collaborators: collaborators_to_json(board_bag)
    );
  end

private

  def labels_to_json(board_bag)
    # TODO: Remove duplications with BoardBag
    board_bag.labels.sort_by(&:name).map do |label|
      {
        id: label.name,
        name: label.name,
        color: "##{LabelPresenter.new(:label, label).font_color}",
        backgroundColor: "##{label.color}",
        checked: label_include?(label)
      }
    end
  end

  def label_include?(label)
    return false if labels.blank?
    labels.any? { |issue_label| issue_label.name == label.name }
  end
end
