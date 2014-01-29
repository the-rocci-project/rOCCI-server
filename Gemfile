source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.0.0'
gem 'rails-api', '~> 0.1.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use Capistrano for deployment
gem 'capistrano', group: :development
gem 'rvm-capistrano', group: :development

# Use debugger
gem 'debugger', group: [:development, :test]

# Use whenever for scheduled jobs
gem 'whenever', require: false

# Use passenger for deployment (standalone or in Apache2)
gem 'passenger', '= 4.0.29'

# Use simplecov for coverage reports
gem 'simplecov', group: [:development, :test]

# Use RSpec for unit tests
gem 'rspec-rails', group: [:development, :test]
gem 'fuubar', group: [:development, :test]

# Use Pry for debugging
gem 'pry-rails', group: [:development, :test]
gem 'pry-rescue', group: [:development, :test]
gem 'pry-stack_explorer', group: [:development, :test]

# Use guard to speed-up devel process
gem 'guard-bundler', group: :development
gem 'guard-test', group: :development
gem 'guard-rails', group: :development

# Use notification libs to integrate guard with pop-ups
gem 'rb-inotify', require: false, group: :development
gem 'libnotify', group: :development

# Use YARD for documentation
gem 'yard', group: :development
gem 'redcarpet', group: :development

# Use bond+hirb to extend irb
#
# Add the following to your ~/.irbrc:
#
# require 'bond'
# require 'hirb'
#
# Bond.start
# Hirb.enable
#
# Or type it in the current irb session.
gem 'bond', group: :development
gem 'hirb', group: :development

# Caching stuff
gem 'dalli'
gem 'kgio'

# AuthN middleware
gem 'warden'

# Sensible logging with LogStash support
gem 'logstasher', git: "git://github.com/shadabahmed/logstasher.git", branch: "master"

# Use Hashie::Mash to simplify hash-related stuff
gem 'hashie'

# Use IceNine to deep-freeze objects
gem 'ice_nine'

# Use occi-core for OCCI stuff
gem 'occi-core', '~> 4.2.5'

# Install gems for each backend from Rails.root/lib/backends/bundles
Dir.glob(File.join(File.dirname(__FILE__), 'lib', 'backends', 'bundles', "Gemfile.*")) do |gemfile|
    eval(IO.read(gemfile), binding)
end