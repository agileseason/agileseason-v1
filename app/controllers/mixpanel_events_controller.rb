class MixpanelEventsController < ApplicationController
  skip_authorization_check unless: -> { current_user }

  CLIENT_SIDE_EVENTS = ['landing']

  def client_event
    if CLIENT_SIDE_EVENTS.include?(params[:event])
      ui_event(params[:event].to_sym)
    end

    head :ok
  end
end
