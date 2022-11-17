#! /bin/bash

# SSH configuration
cat /vagrant/vagrant_files/authorized_keys >> /root/.ssh/authorized_keys
cat /vagrant/vagrant_files/authorized_keys >> /home/vagrant/.ssh/authorized_keys
