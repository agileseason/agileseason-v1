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

  private

  def display_labels(hidden_label_name)
    labels.select { |label| label.name != hidden_label_name }
  end

  def color(label)
    if label.color.hex >= 16_525_609 || label.color.hex <= 5_446_119
      "fff"
    else
      "000"
    end
  end
end
