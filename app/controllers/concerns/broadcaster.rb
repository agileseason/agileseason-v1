module Broadcaster
  extend ActiveSupport::Concern

  def broadcast_column(column, force = false)
    broadcast({ action: 'update_column', column_id: column.id }, force)
  end

private

  def broadcast(options, force = false)
    client_id = force ? 'system_message' : current_user.remember_token
    FayePusher.broadcast_board(
      client_id,
      @board,
      { action: action_name }.merge(options)
    )
  end
end
