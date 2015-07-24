class LabelPresenter < Keynote::Presenter
  presents :label
  delegate :color, :name, to: :label

  def css_style
    border_color = color == 'ffffff' ? 'eee' : color
    "background-color:##{color}; color:##{font_color}; border: 1px solid ##{border_color}"
  end

  def font_color
    case color
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
end
