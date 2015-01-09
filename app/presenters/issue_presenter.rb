class IssuePresenter < Keynote::Presenter
  presents :issue
  delegate :labels, to: :issue

  def labels_html(column_name)
    build_html do
      display_labels(column_name).each do |label|
        div class: :label, style: "background-color:##{label.color}; color:##{color(label)}" do
          label.name
        end
      end
    end
  end

  # FIX : Public method only for test - not single responsibility.
  # FIX : Need extract to gem.
  def color(label)
    hex = label.color.hex
    if hex == 16_777_215 # white
      '000'
    elsif hex >= 16_525_609 # red
      'fff'
    elsif hex <= 5_446_119 # dark blue
      'fff'
    else
      '000'
    end
  end

  def current_column?(columns, current_column)
    columns.any?{ |column| current_column == column.name.split('] ').last}
  end

  private

  def display_labels(hidden_label_name)
    labels.select { |label| label.name != hidden_label_name }
  end
end
