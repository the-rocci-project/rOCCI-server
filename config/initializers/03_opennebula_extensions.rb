# Load OpenNebula monkey-patches from Rails.root/lib/open_nebula
Dir[Rails.root.join('lib', 'open_nebula', '*.rb')].each { |file| require file.gsub('.rb', '') }
