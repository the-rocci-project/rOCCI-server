module Opennebula
  class OpennebulaJob < ApplicationJob
    queue_as :opennebula

    # Default timeout in seconds
    DEFAULT_TIMEOUT = 900

    # :nodoc:
    HELPER_NS = 'Backends::Opennebula::Helpers'.freeze

    rescue_from(Errors::JobError) do |ex|
      logger.error "Delayed job failed: #{ex}"
    end

    rescue_from(Errors::Backend::EntityTimeoutError) do |_ex|
      logger.error "Timed out while waiting for job completion [#{DEFAULT_TIMEOUT}s]"
    end

    rescue_from(Errors::Backend::EntityRetrievalError) do |ex|
      logger.error "Failed to get instance state when waiting: #{ex}"
    end

    rescue_from(Errors::Backend::RemoteError) do |ex|
      logger.fatal "Failed during transition: #{ex}"
    end

    # Performs job in OpenNebula with given arguments.
    #
    # @param secret [String] credentials for ONe
    # @param endpoint [String] ONe XML RPC endpoint
    # @param args [Hash] OpenNebula job arguments
    def perform(secret, endpoint, _args = {})
      @client = ::OpenNebula::Client.new(secret, endpoint)
    end

    private

    # :nodoc:
    def virtual_machine(identifier, state = nil)
      virtual_machine = ::OpenNebula::VirtualMachine.new_with_id(identifier, @client)

      if state
        Backends.const_get(HELPER_NS)::Waiter.wait_until(virtual_machine, state, DEFAULT_TIMEOUT, :state_str)
      else
        handle { virtual_machine.info }
      end

      virtual_machine
    end

    # :nodoc:
    def image(identifier, _state = nil)
      image = ::OpenNebula::Image.new_with_id(identifier, @client)
      handle { image.info }
      image
    end

    # :nodoc:
    def handle
      rc = yield
      raise rc.message if ::OpenNebula.is_error?(rc)
      rc
    rescue StandardError => ex
      raise Errors::JobError, ex.message
    end
  end
end
