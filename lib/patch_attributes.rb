module PatchAttributes
  def update_attribute
    resource.send("#{params[:name]}=", params[:value])
    resource.save!
    render_result
  end

  def resource
    @resource ||= fetch_resource
  end

  def fetch_resource
    raise 'Please define fetch_resource method'
  end

  def render_result
    render nothing: true
  end
end
