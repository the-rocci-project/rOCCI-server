unless Rails.env.production?
  require 'mixlib/shellout'

  # :nodoc:
  def exec_vagrant(*args)
    runcmd '/usr/bin/vagrant', *args
  end

  # :nodoc:
  def exec_bash(*args)
    runcmd '/bin/bash', *args
  end

  # :nodoc:
  def runcmd(executable, *args)
    cmd = Mixlib::ShellOut.new(executable, *args)

    cmd.live_stdout = STDOUT
    cmd.live_stderr = STDERR
    cmd.run_command

    %i[live_stdout live_stderr].each { |s| cmd.send(s).flush }
    cmd.error!
  end

  desc 'Run integration tests'
  task integration: %w[integration:dummy integration:one]

  namespace :integration do
    desc 'Run integration tests with Dummy'
    task dummy: %i[vagrant_up tests_dummy vagrant_destroy]

    desc 'Run integration tests with OpenNebula'
    task :one do
      ENV['ROCCI_SERVER_INTEGRATION_ONE'] = 'yes'
      tasks = %w[integration:vagrant_up integration:tests_one integration:vagrant_destroy]
      tasks.each do |name|
        Rake::Task[name].reenable
        Rake::Task[name].invoke
      end
    end

    desc 'Provision virtual machines for integration tests'
    task :vagrant_up do
      puts 'Running vagrant-up'

      machines = []
      machines << 'one' if ENV['ROCCI_SERVER_INTEGRATION_ONE'] == 'yes'
      machines << 'rocci-server'
      exec_vagrant 'up', *machines

      puts 'Finished running vagrant-up'
    end

    desc 'Tear down virtual machines provisioned for integration tests'
    task :vagrant_destroy do
      puts 'Running vagrant-destroy'
      exec_vagrant 'destroy', '-f', 'one', 'rocci-server'
      puts 'Finished running vagrant-destroy'
    end

    desc 'Execute integration suite for Dummy backend'
    task :tests_dummy do
      exec_bash Rails.root.join('test', 'integration', 'dummy.sh').to_s
    end

    desc 'Execute integration suite for OpenNebula backend'
    task :tests_one do
      exec_bash Rails.root.join('test', 'integration', 'one.sh').to_s
    end
  end
end
