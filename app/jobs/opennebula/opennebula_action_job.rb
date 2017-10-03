module Opennebula
  class OpennebulaActionJob < OpennebulaJob
    # Performs actions on objects with the given `identifier`.
    #
    # @param secret [String] credentials for ONe
    # @param endpoint [String] ONe XML RPC endpoint
    # @param args [Hash] OpenNebula job arguments
    # @option args [String] :identifier object identifier
    # @option args [String] :action_name name of the action to execute
    # @option args [Hash] :action_attributes attributes of the action to execute
    # @option args [String] :required_state state to wait for
    def perform(secret, endpoint, args = {})
      super

      amtd = "action_#{args.fetch(:action_name)}".freeze
      raise 'Unsupported action' unless self.class::ACTIONS.include?(args.fetch(:action_name))

      logger.debug { "Calling #{amtd} for action #{args.fetch(:action_name).inspect} on #{self.class::ELM_NAME}" }
      obj = send(self.class::ELM_NAME, args.fetch(:identifier), args.fetch(:required_state, nil))

      run_primitives! amtd, obj, args.fetch(:action_attributes)
    end

    private

    # :nodoc:
    def run_primitives!(amtd, obj, action_attributes)
      send "#{amtd}_pre", obj, action_attributes if respond_to?("#{amtd}_pre")
      rc = handle { send amtd, obj, action_attributes }
      send "#{amtd}_post", rc if respond_to?("#{amtd}_post")
    end
  end
end
