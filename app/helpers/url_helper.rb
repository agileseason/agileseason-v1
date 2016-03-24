module UrlHelper
  def date_to_url(date)
    date.strftime('%d-%m-%Y')
  end

  def current_date?(date)
    params[:from] == date_to_url(date)
  end
end
