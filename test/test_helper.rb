require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

module HelpfulTestConstants
  TOKEN = 'am9obm55Om9wZW5uZWJ1bGEK'.freeze
  DUMMY_ID = 'a262ad95-c093-4814-8c0d-bc6d475bb845'.freeze

  LOCATION_FORMATS = %w[text/uri-list].freeze
  LEGACY_FORMATS = %w[text/plain text/occi].freeze
  FULL_FORMATS = %w[application/json application/occi+json].freeze
  FORMATS = [LEGACY_FORMATS, FULL_FORMATS].flatten.freeze
  ALL_FORMATS = [LOCATION_FORMATS, FORMATS].flatten.freeze
  DEFAULT_FORMAT = FULL_FORMATS.first.freeze

  ENTITIES = %w[
    compute network storage ipreservation securitygroup
    networkinterface storagelink securitygrouplink
  ].freeze
  MULTI_ENTITIES = %w[entity resource link].freeze
end
