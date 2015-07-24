class IssuePresenter < Keynote::Presenter
  presents :issue
  delegate :labels, :number, to: :issue

  def labels_html
    build_html do
      div(class: 'b-issue-labels') do
        if labels.present?
          labels.sort_by(&:name).each do |label|
            div.label(label.name, style: k(:label, label).css_style)
          end
        end
      end
    end
  end

  def labels_edit_html(board)
    build_html do
      board.labels.sort_by(&:name).each do |label|
        div.label(style: k(:label, label).css_style) do
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

  def label_include?(label)
    labels.any? { |issue_label| issue_label.name == label.name }
  end

  def due_date_at
    issue.due_date_at.try(:utc).try(:strftime, '%b %d %H:%M')
  end

  def archived?(board)
    IssueStatService.archived?(board, number)
  end

  def body_empty?
    issue.body.blank? || issue.body.strip.start_with?('<!---')
  end

  def title
    issue.title.slice(0, 1).capitalize + issue.title.slice(1..-1)
  end
end
