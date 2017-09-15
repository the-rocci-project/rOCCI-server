module Opennebula
  class ComputeResizeJob < OpennebulaJob
    # State to wait for
    TARGET_STATE = 'UNDEPLOYED'.freeze

    # Performs resize on VirtualMachine with the given `identifier`.
    #
    # @param secret [String] credentials for ONe
    # @param endpoint [String] ONe XML RPC endpoint
    # @param args [Hash] OpenNebula job arguments
    # @option args [String] :identifier virtual machine identifier
    # @option args [Hash] :size sizing attributes
    def perform(secret, endpoint, args = {})
      super
      vm = virtual_machine(args.fetch(:identifier), TARGET_STATE)
      template = size_template(args.fetch(:size))

      handle { vm.resize(template, true) }
      handle { vm.resume }
    end

    private

    # :nodoc:
    def size_template(size)
      resize_template = ''
      resize_template << "VCPU = #{size['occi.compute.cores']}\n"
      resize_template << "CPU = #{size['occi.compute.speed'] * size['occi.compute.cores']}\n"
      resize_template << "MEMORY = #{(size['occi.compute.memory'] * 1024).to_i}"
    end
  end
end
