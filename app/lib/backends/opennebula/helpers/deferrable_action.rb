module Backends
  module Opennebula
    module Helpers
      module DeferrableAction
        # :nodoc:
        def deferred_action(identifier, action_instance, klass, state_attr_name)
          logger.debug { "#{self.class}: Triggering action on instance #{identifier} with #{action_instance.inspect}" }
          action = action_instance.action

          obj = instance(identifier)
          unless obj.actions.include?(action)
            raise Errors::Backend::EntityActionError, "Action cannot be used in state #{obj[state_attr_name]}"
          end

          klass.perform_later(
            client_secret(options), options.fetch(:endpoint),
            identifier: identifier, action_name: action.term,
            action_attributes: serializable_attributes(action_instance.attributes, :value)
          )

          Occi::Core::Collection.new
        end

        # :nodoc:
        def serializable_attributes(attributes, type)
          Hash[attributes.map { |k, v| [k, v.send(type)] }]
        end
      end
    end
  end
end
