module Opennebula
  class ComputeActionJob < OpennebulaActionJob
    # Supported actions
    ACTIVE_ACTIONS = %w[stop restart suspend].freeze
    INACTIVE_ACTIONS = %w[start save].freeze
    ACTIONS = [ACTIVE_ACTIONS, INACTIVE_ACTIONS].flatten.freeze

    # Template/image attributes to remove after save
    PURGE_ATTRIBUTES = %w[TEMPLATE/CLOUDKEEPER_ID TEMPLATE/CLOUDKEEPER_EXPIRED].freeze

    # :nodoc:
    ELM_NAME = 'virtual_machine'.freeze

    protected

    # :nodoc:
    def job_cleanup!
      super
      return unless @_cleanup_templates

      logger.debug { "Running after-fail cleanup on #{@_cleanup_templates.inspect}" }
      @_cleanup_templates.each do |tpl|
        logger.warn "Cleaning up TEMPLATE##{tpl} after save action failed"
        begin
          handle { template(tpl).delete(true) }
        rescue StandardError => ex
          logger.error "Failed to clean up TEMPLATE##{tpl}: #{ex}"
        end
      end
    end

    private

    # :nodoc:
    def action_stop(vm, _attributes)
      logger.debug { "Calling POWEROFF on VM with ID #{vm['ID'].inspect}" }
      vm.poweroff true
    end

    # :nodoc:
    def action_restart(vm, _attributes)
      logger.debug { "Calling REBOOT on VM with ID #{vm['ID'].inspect}" }
      vm.reboot true
    end

    # :nodoc:
    def action_suspend(vm, _attributes)
      logger.debug { "Calling SUSPEND on VM with ID #{vm['ID'].inspect}" }
      vm.suspend
    end

    # :nodoc:
    def action_start(vm, _attributes)
      logger.debug { "Calling RESUME on VM with ID #{vm['ID'].inspect}" }
      vm.resume
    end

    # :nodoc:
    def action_save(vm, attributes)
      new_name = attributes['name'].present? ? attributes['name'] : "saved-compute-#{vm['ID']}-#{Time.now.utc.to_i}"

      logger.debug { "Saving running virtual machine with ID #{vm['ID'].inspect} as #{new_name.inspect}" }
      rc = vm.save_as_template new_name, true
      @_cleanup_templates = [rc] unless ::OpenNebula.is_error?(rc)
      rc
    end

    # :nodoc:
    def action_save_post(template_id)
      logger.debug { "Running post-save actions on template with ID #{template_id.inspect}" }

      tpl = template(template_id)
      purge_disks_attributes! tpl
      purge_attributes! tpl
    end

    # :nodoc:
    def purge_disks_attributes!(template)
      template.each('TEMPLATE/DISK') do |disk|
        if disk['IMAGE_ID'].present?
          purge_attributes! image(disk['IMAGE_ID'])
        elsif disk['IMAGE'].present?
          purge_attributes! image_by_name(disk['IMAGE'])
        end
      end
    end

    # :nodoc:
    def purge_attributes!(obj)
      logger.debug { "Removing attributes #{PURGE_ATTRIBUTES.inspect} from #{obj.inspect}" }
      PURGE_ATTRIBUTES.each { |attrib| obj.delete_element(attrib) }
      handle { obj.update(obj.template_str) }
    end
  end
end
