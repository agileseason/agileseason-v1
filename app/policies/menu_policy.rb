class MenuPolicy
  def initialize(controller, board)
    @controller = controller
    @board = board
  end

  def visible?
    return false if docs?
    return false if board_broken?
    true
  end

private

  def board_broken?
    return false unless @controller.class == BoardsController
    return false unless @controller.action_name == 'show'
    !@board&.persisted?
  end

  def docs?
    @controller.class == DocsController
  end
end
