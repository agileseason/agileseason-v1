module PatchAttributes
  def update_attribute
    if resource.attributes.include?(params[:name])
      # FIX : Think about send some message-alert for user if resource invalid.
      resource.update_attribute(params[:name], params[:value])
    end
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
