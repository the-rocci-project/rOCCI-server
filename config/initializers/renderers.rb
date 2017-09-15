# Render OCCI locations into HTTP body for 'text/uri-list'
ActionController::Renderers.add :uri_list do |obj, _options|
  if obj.respond_to?(:to_a)
    self.content_type = Mime::Type.lookup_by_extension(:uri_list)
    obj.to_a.join "\n"
  else
    self.content_type = Mime::Type.lookup_by_extension(:text)
    obj.message
  end
end

# Render OCCI into HTTP headers for 'text/occi'
ActionController::Renderers.add :headers do |obj, _options|
  self.content_type = Mime::Type.lookup_by_extension(:headers)
  headers.merge! obj.to_headers
  '' # body is empty here
end

ActionController::Renderers.add :text do |obj, _options|
  self.content_type = Mime::Type.lookup_by_extension(:text)
  obj.to_text
end

ActionController::Renderers.add :json do |obj, _options|
  self.content_type = Mime::Type.lookup_by_extension(:json)
  obj.to_json
end

ActionController::Renderers.add :occi_json do |obj, _options|
  self.content_type = Mime::Type.lookup_by_extension(:occi_json)
  obj.to_json
end
