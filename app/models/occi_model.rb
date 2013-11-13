# Provides access to Occi::Model instances with added
# functionality:
# * Wraps Occi::Model instantiation
# * Automatically performs necessary registrations
# * Helps with filtering
class OcciModel

  class << self

    # Instantiates Occi::Model and registers necessary extensions.
    #
    # @example
    #    OcciModel.get #=> #<Occi::Model>
    #
    # @param filter [Occi::Collection, Occi::Core::Category, String] filtration parameters
    # @return [Occi::Model] an Occi::Model instance ready to use
    def get(filter = nil)
      filter ? get_filtered(filter) : model_factory
    end

    # Instantiates Occi::Model, registers necessary extensions
    # and filters its content according to `filter`.
    #
    # @example
    #    OcciModel.get_filtered(collection) #=> Occi::Model
    #
    # @param filter [Occi::Collection, Occi::Core::Category, String] filtration parameters
    # @return [Occi::Model] an Occi::Model instance ready to use
    def get_filtered(filter)
      raise ArgumentError, 'Filter must not be nil!' unless filter

      Rails.logger.debug "[#{self}] Building OCCI model with filter: #{filter.inspect}"
      filter = filter.kinds.first if filter.respond_to?(:kinds)
      model_factory.get(filter)
    end

    # Instantiates Occi::Model and registers necessary extensions
    # according to `with_extensions`. Extensions inlcude `resource_tpl`
    # and `os_tpl` mixins, new kinds and actions etc.
    #
    # @param with_extensions [true, false] flag allowing backend-specific extensions
    # @return [Occi::Model] an Occi::Model instance ready to use
    def model_factory(with_extensions = true)
      model = Occi::Model.new
      model.register_infrastructure

      if with_extensions
        Rails.logger.debug "[#{self}] Building OCCI model with extensions"
        model.register_collection(get_extensions)
        model.register_collection(mixins_as_a_coll(Backend.instance.os_tpl_get_all))
        model.register_collection(mixins_as_a_coll(Backend.instance.resource_tpl_get_all))
      end

      model
    end

    # Gets backend-specific extensions which should be merged
    # into Occi::Model of the server.
    #
    # @example
    #    collection = get_extensions #=> #<Occi::Collection>
    #    collection.kinds   #=> #<Occi::Core::Kinds>
    #    collection.mixins  #=> #<Occi::Core::Mixins>
    #    collection.actions #=> #<Occi::Core::Actions>
    #
    # @return [Occi::Collection] a collection of extensions containing kinds, mixins and actions
    def get_extensions
      collection = Occi::Collection.new

      # Load all JSON files in the given directory, these contain
      # JSON rendering of OCCI kind/mixin/action definitions
      path = Rails.root.join('etc', 'backends', Backend.instance.backend_name, 'model')
      Rails.logger.debug "[#{self}] Getting extensions from #{path}"
      Dir.glob(File.join(path, '**', '*.json')) do |file|
        Rails.logger.debug "[#{self}] Reading #{file}"
        parsed = JSON.parse(File.read(file))
        coll = Occi::Collection.new(parsed)

        collection.merge! coll
      end

      collection
    end

    # Wraps given collection of mixins in an Occi::Collection instance
    #
    # @example
    #    mixins = Occi::Core::Mixins.new
    #    coll = mixins_as_a_coll(mixins) #=> #<Occi::Collection>
    #    coll.mixins == mixins #=> true
    #
    # @param mixins [Occi::Core::Mixins]
    # @return [Occi::Collection]
    def mixins_as_a_coll(mixins)
      raise ArgumentError, 'Mixins is a mandatory argument!' unless mixins
      collection = Occi::Collection.new
      collection.mixins = mixins

      collection
    end

  end

  private_class_method :model_factory
  private_class_method :get_extensions
  private_class_method :mixins_as_a_coll

end