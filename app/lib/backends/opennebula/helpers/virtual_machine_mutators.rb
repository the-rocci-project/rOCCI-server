module Backends
  module Opennebula
    module Helpers
      module VirtualMachineMutators
        # Static user_data encoding
        USERDATA_ENCODING = 'base64'.freeze

        # :nodoc:
        def modify_basic!(template, compute, os_tpl)
          template.modify_element 'TEMPLATE/NAME', compute['occi.core.title'] || ::SecureRandom.uuid
          template.modify_element 'TEMPLATE/DESCRIPTION', compute['occi.core.summary'] || ''
          template.modify_element 'TEMPLATE/TEMPLATE_ID', os_tpl
        end

        # :nodoc:
        def set_context!(template, compute)
          template.modify_element 'TEMPLATE/CONTEXT/SSH_PUBLIC_KEY',
                                  compute['occi.credentials.ssh.publickey'] \
                                  || compute['org.openstack.credentials.publickey.data'] \
                                  ||''
          template.modify_element 'TEMPLATE/CONTEXT/USERDATA_ENCODING', USERDATA_ENCODING
          template.modify_element 'TEMPLATE/CONTEXT/USER_DATA',
                                  compute['occi.compute.userdata'] \
                                  || compute['org.openstack.compute.user_data'] \
                                  || ''
        end

        # :nodoc:
        def set_size!(template, compute)
          template.modify_element 'TEMPLATE/VCPU', compute['occi.compute.cores']
          template.modify_element 'TEMPLATE/CPU', (compute['occi.compute.speed'] * compute['occi.compute.cores'])
          template.modify_element 'TEMPLATE/MEMORY', (compute['occi.compute.memory'] * 1024).to_i
          template.modify_element 'TEMPLATE/DISK[1]/SIZE', (compute['occi.compute.ephemeral_storage.size'] * 1024).to_i
        end

        # :nodoc:
        def set_security_groups!(template, compute)
          sgs = compute.securitygrouplinks.map(&:target_id).join(',')

          idx = 1
          template.each('TEMPLATE/NIC') do |_nic|
            logger.debug { "#{self.class}: Setting SecurityGroups #{sgs.inspect} on NIC[#{idx}]" }
            template.modify_element "TEMPLATE/NIC[#{idx}]/SECURITY_GROUPS", sgs
            idx += 1
          end
        end

        # :nodoc:
        def set_cluster!(template, compute)
          az = compute.availability_zone ? compute.availability_zone.term : nil
          return unless az

          sched_reqs = template['TEMPLATE/SCHED_REQUIREMENTS'] || ''
          sched_reqs << ' & ' if sched_reqs.present?
          sched_reqs << "(CLUSTER_ID = #{az})"

          logger.debug { "#{self.class}: Setting SCHED_REQUIREMENTS to #{sched_reqs.inspect}" }
          template.modify_element 'TEMPLATE/SCHED_REQUIREMENTS', sched_reqs
        end

        # :nodoc:
        def add_custom!(template_str, _compute)
          logger.debug { "#{self.class}: Adding identity #{active_identity.inspect} to template" }
          template_str << "\n USER_IDENTITY=\"#{active_identity}\""
          template_str << "\n USER_X509_DN=\"#{active_identity}\""
        end

        # :nodoc:
        def add_pci!(template_str, compute)
          return unless compute['eu.egi.fedcloud.compute.pci.count']

          pci = {
            vendor: compute['eu.egi.fedcloud.compute.pci.vendor'],
            klass: compute['eu.egi.fedcloud.compute.pci.class'],
            device: compute['eu.egi.fedcloud.compute.pci.device']
          }
          data = { instances: [] }
          compute['eu.egi.fedcloud.compute.pci.count'].times { data[:instances] << pci }

          logger.debug { "#{self.class}: Adding PCI(s) #{data[:instances].first.inspect}" }
          add_erb! template_str, data, 'compute_pci.erb'
        end

        # :nodoc:
        def add_nics!(template_str, compute)
          data = {
            instances: compute.networkinterfaces,
            security_groups: compute.securitygrouplinks.map(&:target_id)
          }
          logger.debug { "#{self.class}: Adding NIC(s) #{data.inspect}" }
          add_erb! template_str, data, 'compute_nic.erb'
        end

        # :nodoc:
        def add_disks!(template_str, compute)
          data = { instances: compute.storagelinks }
          logger.debug { "#{self.class}: Adding DISK(s) #{data.inspect}" }
          add_erb! template_str, data, 'compute_disk.erb'
        end

        # :nodoc:
        def add_erb!(template_str, data, template_file)
          template_path = File.join(template_directory, template_file)

          logger.debug { "#{self.class}: Rendering ERB in #{template_path.inspect} with #{data.inspect}" }
          template_str << "\n"
          template_str << erb_render(template_path, data)
        end
      end
    end
  end
end
