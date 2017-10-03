module Opennebula
  class StorageActionJob < OpennebulaActionJob
    # Supported actions
    ONLINE_ACTIONS = %w[backup].freeze
    ACTIONS = [ONLINE_ACTIONS].flatten.freeze

    # :nodoc:
    ELM_NAME = 'image'.freeze

    private

    # :nodoc:
    def action_backup(image, _attributes)
      new_name = "storage-#{image['ID']}-#{Time.now.utc.to_i}"

      logger.debug { "Cloning image #{image['ID']} into #{new_name.inspect}" }
      image.clone
    end
  end
end
