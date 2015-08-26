class PreferencesController < ApplicationController
  include PreferenceHelper

  def update
    preference_params.each { |key, value| public_send("#{key}=", value) }
    redirect_to :back
  end

  private

  def preference_params
    params.
      required(:preference).
      permit(:rolling_average_window)
  end
end
