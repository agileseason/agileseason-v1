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

  def labels_edit_html(board)
    build_html do
      board.labels.sort_by(&:name).each do |label|
        label(style: k(:label, label).css_style) do
          options = {
            type: :checkbox,
            id: label.name,
            name: 'issue[labels][]',
            value: "#{label.name}",
            'data-url' => "#{update_board_issues_url(board, issue)}"
          }

          options[:checked] = :checked if label_include?(label)

          input(options)
          div(label.name, class: 'label-name')
        end
      end
    end
  end

  def labels_to_json(board_bag)
    board_bag.labels.sort_by(&:name).map do |label|
      { id: label.name, name: label.name, color: "##{label.color}", checked: label_include?(label) }
    end
  end

  def collaborators_to_json(board_bag)
    board_bag.collaborators.map do |user|
      { login: user.login, avatarUrl: user.avatar_url }
    end
  end

  def label_include?(label)
    return false if labels.blank?
    labels.any? { |issue_label| issue_label.name == label.name }
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
end
