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
      rc = vm.save_as_template new_name, true
      @_cleanup_templates = [rc] unless ::OpenNebula.is_error?(rc)
      rc
    end

    # :nodoc:
    def action_save_post(template_id)
      tpl = template(template_id)
      purge_disks_attributes! tpl
      purge_attributes! tpl
    end

    # :nodoc:
    def purge_disks_attributes!(template)
      template.each_xpath('TEMPLATE/DISK') do |disk|
        if disk['IMAGE_ID'].present?
          purge_attributes! image(disk['IMAGE_ID'])
        elsif disk['IMAGE'].present?
          purge_attributes! image_by_name(disk['IMAGE'])
        end
      end
    end

    # :nodoc:
    def purge_attributes!(obj)
      PURGE_ATTRIBUTES.each { |attrib| obj.delete_element(attrib) }
      handle { obj.update(obj.template_str) }
    end
  end
end
