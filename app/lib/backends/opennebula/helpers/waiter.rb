require 'timeout'

module Backends
  module Opennebula
    module Helpers
      class Waiter
        # Default polling interval
        WAITER_STEP = 5

        # Default timeout
        TIMEOUT = 60

        # Early exit state
        EARLY_EXIT_ON = 'FAILURE'.freeze

        attr_accessor :waitee, :refresher, :waiter_step, :timeout, :logger

        def initialize(args = {})
          @waitee = args.fetch(:waitee)
          @refresher = args.fetch(:refresher)
          @waiter_step = args.fetch(:waiter_step, WAITER_STEP)
          @timeout = args.fetch(:timeout, TIMEOUT)
          @logger = args.fetch(:logger, Rails.logger)
        end

        # Waits until `waitee` changes state to a state matching at least one of the hashes
        # provided as `states`. Each state should be declared as `reader: expected_value`.
        #
        # @param states [Array] target states
        def wait_until(states)
          Timeout.timeout(timeout, Errors::Backend::EntityTimeoutError) do
            loop do
              sleep waiter_step
              refresher.call waitee
              early_fail!
              break if wanted?(states)
            end
          end

          yield waitee if block_given?
        end

        private

        # :nodoc:
        def wanted?(states)
          states.each do |state|
            fits = state.reduce(true) { |memo, (k, v)| memo && waitee.send(k) == v }
            return true if fits
          end

          false
        end

        # :nodoc:
        def early_fail!
          return unless waitee.respond_to?(:lcm_state_str)
          return unless waitee.lcm_state_str.include?(EARLY_EXIT_ON)
          raise Errors::Backend::RemoteError, "Resource #{waitee['ID']} is stuck in state #{EARLY_EXIT_ON}"
        end
      end
    end
  end
end
