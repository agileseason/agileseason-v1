class SidekiqConstraint
  def matches?(request)
    return false unless request.session[:remember_token]
    user = User.find_by(remember_token: request.session[:remember_token])
    user && user.admin?
  end
end
