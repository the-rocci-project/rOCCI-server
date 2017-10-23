module Opennebula
  class OpennebulaJob < ApplicationJob
    queue_as :opennebula

    # Default timeout in seconds
    DEFAULT_TIMEOUT = 900

    rescue_from(Errors::JobError) do |ex|
      logger.error "Delayed job failed: #{ex}"
      job_cleanup!
    end

    rescue_from(Errors::Backend::EntityTimeoutError) do |_ex|
      logger.error "Timed out while waiting for job completion [#{DEFAULT_TIMEOUT}s]"
      job_cleanup!
    end

    rescue_from(Errors::Backend::EntityRetrievalError) do |ex|
      logger.error "Failed to get instance state when waiting: #{ex}"
      job_cleanup!
    end

    rescue_from(Errors::Backend::RemoteError) do |ex|
      logger.fatal "Failed during transition: #{ex}"
      job_cleanup!
    end

    # Performs job in OpenNebula with given arguments.
    #
    # @param secret [String] credentials for ONe
    # @param endpoint [String] ONe XML RPC endpoint
    # @param args [Hash] OpenNebula job arguments
    def perform(secret, endpoint, _args = {})
      @client = ::OpenNebula::Client.new(secret, endpoint)
    end

    protected

    # :nodoc:
    def job_cleanup!; end

    private

    # :nodoc:
    def virtual_machine(identifier, state = nil)
      virtual_machine = oneject('virtual_machine', identifier)
      if state
        refresher = ->(obj) { handle { obj.info } }
        waiter = Backends::Opennebula::Helpers::Waiter.new(
          waitee: virtual_machine, logger: logger, timeout: DEFAULT_TIMEOUT, refresher: refresher
        )
        waiter.wait_until [{ state_str: state }]
      end
      virtual_machine
    end

    # :nodoc:
    def image(identifier, _state = nil)
      oneject 'image', identifier
    end

    # :nodoc:
    def image_by_name(name, _state = nil)
      oneject_by_name 'image', name
    end

    # :nodoc:
    def template(identifier, _state = nil)
      oneject 'template', identifier
    end

    # :nodoc:
    def oneject(type, identifier)
      logger.debug { "Getting #{type} with ID #{identifier.inspect}" }
      obj = ::OpenNebula.const_get(type.classify).new_with_id(identifier, @client)
      handle { obj.info }
      obj
    end

    # :nodoc:
    def oneject_by_name(type, name)
      logger.debug { "Getting #{type} by name #{name.inspect}" }
      obj = ::OpenNebula.const_get("#{type.classify}Pool").new(@client)
      handle { obj.info_mine }
      obj.detect { |elm| elm['NAME'] == name }
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
