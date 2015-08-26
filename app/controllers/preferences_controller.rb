class PreferencesController < ApplicationController
  include PreferenceHelper

  def update
    preference_params.each do |key, value|
      self.public_send("#{key}=", value)
    end
    redirect_to :back
  end

  private

  def preference_params
    params.
      required(:preference).
      permit(:rolling_average_window)
  end
end
