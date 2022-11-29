# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Default box image
  config.vm.box = "ubuntu/jammy64"  
  
  # Plugins check
  unless Vagrant.has_plugin?("vagrant-hosts")
    raise 'vagrant-hosts is not installed! "vagrant plugin install vagrant-hosts" is needed to be ran first!'
  end
  unless Vagrant.has_plugin?("vagrant-vbguest")
    raise 'vagrant-vbguest is not installed! "vagrant plugin install vagrant-vbguest" is needed to be ran first!'
  end

  # Default Virtualbox provider configuration
  config.vm.provider "virtualbox" do |vb|
    # UI
    vb.gui = false

    # VM hardware spec
    vb.customize ["modifyvm", :id, "--cpus", "4"]
    vb.customize ["modifyvm", :id, "--memory", 4096]
    vb.customize ["modifyvm", :id, "--uartmode1", "disconnected" ]
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
  end

  # Hosts configuration
  config.vm.provision :hosts do |provisioner|
    provisioner.sync_hosts = true
    provisioner.autoconfigure = true
    provisioner.imports = ['global', 'virtualbox']
    provisioner.exports = {
      'virtualbox' => [
        ['@vagrant_private_networks', ['@vagrant_hostnames']],
      ],
    }
  end

  # Variables
  NUM_OF_NODES = 3
  
  # Virtual machines
  config.vm.define 'awx_controller' do |awx_controller|
    awx_controller.vm.network "private_network", ip: "192.168.58.110"
    awx_controller.vm.hostname = 'awx-controller.tests.net'
    [5080, 5432].each do |port|
      awx_controller.vm.network "forwarded_port", guest: port, host: port, protocol: "tcp"
    end
    awx_controller.vm.provision :shell, path: './vagrant_files/awx-server.sh', args: NUM_OF_NODES
  end
  
  
  (1..NUM_OF_NODES).each do |i|
    config.vm.define "guest#{i}" do |guest|
      guest.vm.network "private_network", ip: "192.168.58.1#{i}"
      guest.vm.hostname = "guest#{i}.tests.net"
      guest.vm.provision :shell, path: './vagrant_files/awx-guests.sh'
    end
  end
end
