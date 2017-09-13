require 'backends/dummy/base'

module Backends
  module Dummy
    class EntityBase < Base
      include Helpers::Entitylike

      # Dummies
      DUMMY_IDS = %w[
        a262ad95-c093-4814-8c0d-bc6d475bb845
        5124f8c0-cecb-41ca-b0c9-106f10c2db1e
        8b3e4362-b761-4eed-a6f3-69e271f90286
      ].freeze

      # @see `Entitylike`
      def list(filter = Set.new)
        logger.debug { "#{self.class}: Listing instances with filter #{filter.inspect}" }
        coll = Occi::Core::Collection.new
        DUMMY_IDS.each { |id| coll << instance(id) }
        coll
      end

      # @see `Entitylike`
      def instance(identifier)
        logger.debug { "#{self.class}: Getting instance with ID #{identifier}" }
        instance = instance_builder.get(self.class.entity_identifier)
        instance['occi.core.id'] = identifier
        instance['occi.core.title'] = identifier
        instance
      end

      # @see `Entitylike`
      def create(instance)
        logger.debug { "#{self.class}: Creating instance from #{instance.inspect}" }
        instance['occi.core.id'] = DUMMY_IDS.first
        instance['occi.core.id']
      end

      # @see `Entitylike`
      def partial_update(identifier, fragments)
        logger.debug { "#{self.class}: Partially updating instance #{identifier} with #{fragments.inspect}" }
        instance identifier
      end

      # @see `Entitylike`
      def update(identifier, new_instance)
        logger.debug { "#{self.class}: Updating instance #{identifier} with #{new_instance.inspect}" }
        instance identifier
      end

      # @see `Entitylike`
      def trigger(identifier, action_instance)
        logger.debug { "#{self.class}: Triggering action on instance #{identifier} with #{action_instance.inspect}" }
        Occi::Core::Collection.new
      end

      # @see `Entitylike`
      def delete(identifier)
        logger.debug { "#{self.class}: Deleting instance #{identifier}" }
        identifier
      end
    end
  end
end
