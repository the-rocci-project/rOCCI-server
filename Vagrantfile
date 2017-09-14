# -*- mode: ruby -*-
# vi: set ft=ruby :
require File.join(File.dirname(__FILE__), 'config', 'version')

VG_REPO     = 'xparak'.freeze
VG_BOX      = 'opennebula'.freeze
VG_BOX_VER  = '5.4.0.build.1'.freeze

VM_SIZE = {
  small: { cpus: 1, memory: 1024 },
  large: { cpus: 2, memory: 2048 }
}.freeze

ROCCI_SERVER_DIR = '/opt/rOCCI-server'.freeze
ONE_ADDR = '192.168.50.2'.freeze
ROCCI_SERVER_ADDR = '192.168.50.5'.freeze

Vagrant.configure('2') do |config|
  config.vm.define 'one', primary: true do |one|
    one.vm.box = "#{VG_REPO}/#{VG_BOX}"
    one.vm.box_version = VG_BOX_VER

    one.vm.network 'forwarded_port', guest: 2633, host: 2633, host_ip: '127.0.0.1' # XML-RPC2
    one.vm.network 'forwarded_port', guest: 9869, host: 9869, host_ip: '127.0.0.1' # GUI
    one.vm.network 'private_network', ip: ONE_ADDR

    one.vm.provider 'virtualbox' do |vb|
      vb.name = "rocci-server_#{VG_BOX}-#{VG_BOX_VER}_sandbox"
      vb.linked_clone = true
      vb.gui = false
      vb.cpus = VM_SIZE[:large][:cpus]
      vb.memory = VM_SIZE[:large][:memory]
    end

    one.vm.provision 'shell', inline: <<-SHELL
      ONE_HOME="/home/vagrant/.one/"

      mkdir -p $ONE_HOME
      cp /var/lib/one/.one/one_auth $ONE_HOME
      chown -R vagrant:vagrant $ONE_HOME
    SHELL

    one.vm.provision 'shell', privileged: false, path: 'examples/opennebula/setup.sh'
  end

  config.vm.define 'rocci-server', autostart: false do |rocci_server|
    rocci_server.vm.box = 'centos/7'

    rocci_server.vm.network 'forwarded_port', guest: 3000, host: 3000, host_ip: '127.0.0.1' # REST
    rocci_server.vm.network 'private_network', ip: ROCCI_SERVER_ADDR

    rocci_server.vm.provider 'virtualbox' do |vb|
      vb.name = "rocci-server-#{ROCCIServer::VERSION}"
      vb.linked_clone = true
      vb.gui = false
      vb.cpus = VM_SIZE[:small][:cpus]
      vb.memory = VM_SIZE[:small][:memory]
    end

    rocci_server.vm.provision 'shell', inline: <<-SHELL
      yum install -y -q curl gcc zlib-devel git patch libyaml-devel autoconf gcc-c++ \
                        readline-devel libffi-devel openssl-devel automake libtool bison \
                        sqlite-devel memcached
      systemctl enable memcached
      systemctl start memcached

      gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
      curl -sSL https://get.rvm.io | bash -s stable
      usermod -a -G rvm vagrant

      source /etc/profile.d/rvm.sh
      rvm autolibs enable
      rvm install 2.4.1
      rvm 2.4.1 do gem install bundler
    SHELL

    rocci_server.vm.provision 'shell', inline: <<-SHELL
      SERVER_DIR="#{ROCCI_SERVER_DIR}"

      if [ -d "$SERVER_DIR" ] ; then
        rm -rf $SERVER_DIR
      fi
      cp -Rp /vagrant $SERVER_DIR
      chown -R vagrant:vagrant $SERVER_DIR
    SHELL

    rocci_server.vm.provision 'shell', privileged: false, inline: <<-SHELL
      SERVER_DIR="#{ROCCI_SERVER_DIR}"
      source /etc/profile.d/rvm.sh

      cd $SERVER_DIR
      rvm 2.4.1 do bundle install --deployment --without development test

      if [ "x#{ENV['ROCCI_SERVER_INTEGRATION_ONE']}" = "xyes" ] ; then
        export ROCCI_SERVER_BACKEND=opennebula
        export ROCCI_SERVER_OPENNEBULA_ENDPOINT=http://#{ONE_ADDR}:2633/RPC2

        rvm 2.4.1 do bundle exec bin/oneresources create --endpoint $ROCCI_SERVER_OPENNEBULA_ENDPOINT
      fi

      export RAILS_ENV=production
      export HOST=0.0.0.0
      export SECRET_KEY_BASE=a271402df66e152767d7b2149b8773adf242401eb8000e02a55a5d452fe2e47f7cf05969b8b77d1acb6319c9286e13ea3311b3e180115e9327482b5ecfa2f353
      rvm 2.4.1 do bundle exec puma --daemon
      sleep 5
    SHELL
  end
end
