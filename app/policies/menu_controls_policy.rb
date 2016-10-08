class MenuControlsPolicy
  def initialize(controller)
    @controller = controller
  end

  def visible?
    return false if @controller.class == SettingsController
    true
  end
end
