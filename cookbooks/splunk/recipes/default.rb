# Cookbook Name:: splunkuf_nonprod
# Recipe:: solaris10_x86_pci.rb
#
# Copyright 2015, Wyndham Hotel Group
#
# All rights reserved - Do Not Redistribute
#

if ! Dir.exists?('/var/sadm/pkg/splunkforwarder')

  remote_file "#{node['splunk']['rpm_file_loc']}" do
    source "#{node['splunk']['package_url']}"
    mode '0640'
    owner 'root'
    group 'root'
  end

   rpm_package "splunkforwarder" do
     source "#{node['splunk']['rpm_file_loc']}"
   end

  execute "#{node['splunk']['install_dir']}/bin/splunk enable boot-start --accept-license --answer-yes" do
    not_if{ File.symlink?('/etc/init.d/splunk') }
  end

  # Note:  Should we configure SMF to manage this service?

  execute '/etc/init.d/splunk stop'
  execute 'chown -R root:root /opt/splunkforwarder'
  execute '/etc/init.d/splunk start'

  execute "#{node['splunk']['install_dir']}/bin/splunk set deploy-poll vsvphxspkudev01:8089 -auth admin:changeme" do
    not_if{ File.exists?("#{node['splunk']['install_dir']}/etc/system/local/deploymentclient.conf") }
  end

  cookbook_file "adminpasswd" do
    path "#{node['splunk']['install_dir']}/etc/passwd"
    mode "0600"
    action :create
  end

  execute '/etc/init.d/splunk restart'

  file "#{node['splunk']['rpm_file_loc']}" do
    action :delete
  end

end
