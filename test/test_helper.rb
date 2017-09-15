require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

module HelpfulTestConstants
  TOKEN = 'am9obm55Om9wZW5uZWJ1bGEK'.freeze

  LOCATION_FORMATS = %w[text/uri-list].freeze
  LEGACY_FORMATS = %w[text/plain text/occi].freeze
  FULL_FORMATS = %w[application/json application/occi+json].freeze
  FORMATS = [LEGACY_FORMATS, FULL_FORMATS].flatten.freeze
  ALL_FORMATS = [LOCATION_FORMATS, FORMATS].flatten.freeze

  ENTITIES = %w[
    compute network storage ipreservation securitygroup
    networkinterface storagelink securitygrouplink
  ].freeze
  MULTI_ENTITIES = %w[entity resource link].freeze
end
