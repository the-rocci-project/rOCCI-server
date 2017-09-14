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

      name = args.fetch(:action_name)
      raise "Unsupported action #{name.inspect}" unless self.class::ACTIONS.include?(name)

      obj = send(
        self.class::ELM_NAME,
        args.fetch(:identifier),
        args.fetch(:required_state, nil)
      )
      handle { send "action_#{name}", obj, args.fetch(:action_attributes) }
    end
  end
end
