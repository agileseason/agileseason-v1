class MixpanelEventsController < ApplicationController
  skip_before_filter :authenticate, unless: -> { current_user }

  CLIENT_SIDE_EVENTS = ['landing']

  def client_event
    if CLIENT_SIDE_EVENTS.include?(params[:event])
      ui_event(params[:event].to_sym)
    end

    render nothing: true
  end
end
