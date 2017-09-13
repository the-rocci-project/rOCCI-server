require 'backends/opennebula/base'

module Backends
  module Opennebula
    class Storage < Base
      include Backends::Helpers::Entitylike
      include Backends::Helpers::AttributesTransferable
      include Backends::Helpers::MixinsAttachable
      include Backends::Helpers::ErbRenderer

      class << self
        # @see `served_class` on `Entitylike`
        def served_class
          Occi::Infrastructure::Storage
        end

        # :nodoc:
        def entity_identifier
          Occi::Infrastructure::Constants::STORAGE_KIND
        end
      end

      # @see `Entitylike`
      def identifiers(filter = Set.new)
        logger.debug { "#{self.class}: Listing identifiers with filter #{filter.inspect}" }
        Set.new(pool(:image, :info_mine).map { |im| im['ID'] })
      end

      # @see `Entitylike`
      def list(filter = Set.new)
        logger.debug { "#{self.class}: Listing instances with filter #{filter.inspect}" }
        coll = Occi::Core::Collection.new
        pool(:image, :info_mine).each { |image| coll << storage_from(image) }
        coll
      end

      # @see `Entitylike`
      def instance(identifier)
        logger.debug { "#{self.class}: Getting instance with ID #{identifier}" }
        storage_from pool_element(:image, identifier, :info)
      end

      # @see `Entitylike`
      def create(instance)
        logger.debug { "#{self.class}: Creating instance from #{instance.inspect}" }
        pool_element_allocate(:image, image_from(instance), candidate_datastore(instance))['ID']
      end

      # @see `Entitylike`
      def trigger(identifier, action_instance)
        logger.debug { "#{self.class}: Triggering action on instance #{identifier} with #{action_instance.inspect}" }

        name = action_instance.action.term
        image = pool_element(:image, identifier)
        client(Errors::Backend::EntityActionError) do
          Constants::Storage::ONLINE_ACTIONS[name].call(image, action_instance)
        end

        Occi::Core::Collection.new
      end

      # @see `Entitylike`
      def delete(identifier)
        logger.debug { "#{self.class}: Deleting instance #{identifier}" }
        image = pool_element(:image, identifier)
        client(Errors::Backend::EntityStateError) { image.delete }
      end

      private

      # Converts a ONe image instance to a valid storage instance.
      #
      # @param image [OpenNebula::Image] instance to transform
      # @return [Occi::Infrastructure::Storage] transformed instance
      def storage_from(image)
        storage = instance_builder.get(self.class.entity_identifier)

        attach_mixins! image, storage
        transfer_attributes! image, storage, Constants::Storage::TRANSFERABLE_ATTRIBUTES
        enable_actions!(storage)

        storage
      end

      # Converts an OCCI storage instance to a valid ONe image template.
      #
      # @param storage [Occi::Infrastructure::Storage] instance to transform
      # @return [String] ONe template
      def image_from(storage)
        template_path = File.join(template_directory, 'storage.erb')
        data = { instance: storage, identity: active_identity }
        erb_render template_path, data
      end

      # :nodoc:
      def attach_mixins!(image, storage)
        storage << server_model.find_regions.first

        ds = pool_element(:datastore, image['DATASTORE_ID'], :info)
        ds.each_xpath('CLUSTERS/ID') do |cid|
          attach_optional_mixin! storage, cid, :availability_zone
        end

        logger.debug { "#{self.class}: Attached mixins #{storage.mixins.inspect} to storage##{storage.id}" }
      end

      # :nodoc:
      def enable_actions!(storage)
        return unless storage['occi.storage.state'] == 'online'
        logger.debug do
          "#{self.class}: Enabling actions #{Constants::Storage::ONLINE_ACTIONS.keys.inspect} on storage##{storage.id}"
        end
        Constants::Storage::ONLINE_ACTIONS.keys.each { |a| storage.enable_action(a) }
      end

      # :nodoc:
      def candidate_datastore(instance)
        azs = instance.availability_zones.map(&:term)
        azs << default_cluster if azs.empty?

        azs.sort!
        cds = pool(:datastore).detect { |ds| suitable?(ds, azs) }
        logger.debug { "#{self.class}: Selecting DS #{cds.inspect} for storage##{instance.id}" }
        cds ? cds.id : raise(Errors::Backend::EntityCreateError, 'Storage spanning requested zones cannot be created')
      end

      # :nodoc:
      def suitable?(ds, azs)
        ds.type_str == 'IMAGE' && (azs - clusters(ds)).empty?
      end

      # :nodoc:
      def clusters(element)
        cids = []
        element.each_xpath('CLUSTERS/ID') { |cid| cids << cid }
        cids
      end

      # :nodoc:
      def whereami
        File.expand_path(File.dirname(__FILE__))
      end
    end
  end
end
