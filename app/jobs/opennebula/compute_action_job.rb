module Opennebula
  class ComputeActionJob < OpennebulaActionJob
    # Supported actions
    ACTIVE_ACTIONS = %w[stop restart suspend].freeze
    INACTIVE_ACTIONS = %w[start save].freeze
    ACTIONS = [ACTIVE_ACTIONS, INACTIVE_ACTIONS].flatten.freeze

    # :nodoc:
    ELM_NAME = 'virtual_machine'.freeze

    private

    # :nodoc:
    def action_stop(vm, _attributes)
      vm.poweroff true
    end

    # :nodoc:
    def action_restart(vm, _attributes)
      vm.reboot true
    end

    # :nodoc:
    def action_suspend(vm, _attributes)
      vm.suspend
    end

    # :nodoc:
    def action_start(vm, _attributes)
      vm.resume
    end

    # :nodoc:
    def action_save(vm, attributes)
      new_name = attributes['name'].present? ? attributes['name'] : "saved-compute-#{vm['ID']}-#{Time.now.utc.to_i}"
      vm.save_as_template new_name, true
    end
  end
end
