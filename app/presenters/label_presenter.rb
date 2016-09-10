class LabelPresenter < Keynote::Presenter
  presents :label
  delegate :color, :name, to: :label

  GITHUB_LIGHT_COLORS = [
    'ffffff', 'e6e6e6', '84b6eb', 'cccccc', 'fbca04', 'f7c6c7',
    'fad8c7', 'bfe5bf', 'bfdadc', 'c7def8', 'bfd4f2', 'd4c5f9',
    'c5def5', 'e99695', 'f9d0c4', 'c2e0c6'
  ]

  def css_style
    border_color = color == 'ffffff' ? 'eee' : color
    "background-color:##{color}; color:##{font_color}; border: 1px solid ##{border_color}"
  end

  def font_color
    return '000' if GITHUB_LIGHT_COLORS.include? color
    'fff'
  end
end
