# Clean-up Rails defaults
Mime::SET.symbols.each { |mime| Mime::Type.unregister(mime) }

## Our MIME Types
# Full renderings
Mime::Type.register 'application/occi+json', :occi_json
Mime::Type.register 'application/json', :json, %w[text/x-json application/jsonrequest]

# Legacy renderings
Mime::Type.register 'text/plain', :text, [], %w[txt]
Mime::Type.register 'text/occi', :headers

# Only for locations
Mime::Type.register 'text/uri-list', :uri_list
