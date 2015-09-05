class Renderable
  def self.to_css(class_value = self)
    class_value.name.underscore.gsub('_', '-')
  end

  def to_css
    Renderable.to_css(self.class)
  end
end
