require 'backends/dummy/entity_base'

module Backends
  module Dummy
    class ModelExtender < Base
      include Helpers::Extenderlike

      # @see `Extenderlike`
      def populate!(model)
        logger.debug { "#{self.class}: Populating model instance with extensions" }
        Warehouse.bootstrap! model
      end
    end
  end
end
