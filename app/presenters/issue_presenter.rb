class IssuePresenter < Keynote::Presenter
  presents :issue
  delegate :labels, :number, to: :issue

  def labels_html
    build_html do
      labels.sort_by(&:name).each do |label|
        div class: :label, style: css_style_for(label) do
          label.name
        end
      end
    end
  end

  def due_date_at
    issue.due_date_at.try(:utc).try(:strftime, '%b %d %H:%M')
  end

  # FIX : Extract work with labels to other presenter. See issues/_new.html.slim
  def css_style_for(label)
    border_color = label.color == 'ffffff' ? 'eee' : label.color
    "background-color:##{label.color}; color:##{color_for(label)}; border: 1px solid ##{border_color}"
  end

  def color_for(label)
    case label.color
    # Github standart colors
    when 'ffffff' then '000'
    when 'e6e6e6' then '000'
    when 'fef2c0' then '000'
    when '84b6eb' then '000'
    when 'cccccc' then '000'
    when 'fbca04' then '000'
    when 'f7c6c7' then '000'
    when 'fad8c7' then '000'
    when 'fef2c0' then '000'
    when 'bfe5bf' then '000'
    when 'bfdadc' then '000'
    when 'c7def8' then '000'
    when 'bfd4f2' then '000'
    when 'd4c5f9' then '000'

    else
      'fff'
    end
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
