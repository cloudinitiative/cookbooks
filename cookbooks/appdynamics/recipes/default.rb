#
# Cookbook Name:: appdynamics
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'jdk-wyn'

temp=Chef::Config[:file_cache_path]

# Installs zip (through apt-get install)
package "zip" do
    action :install
end

log "Starting installation of AppDynamics Agents..."

if !File.exist?("#{temp}/appserveragent.zip")
    remote_file "#{temp}/appserveragent.zip" do
         #source "http://vsvphxupoc02.hotelgroup.com/filerepo/appdynamics/appserveragent.zip"
         source "https://s3-us-west-2.amazonaws.com/aws-team/430864_anita/AppServerAgent-4.1.1.2.zip"
         mode 00777
    end
end

if !File.exist?("#{temp}/machineagent.zip")
    remote_file "#{temp}/machineagent.zip" do
         #source "http://vsvphxupoc02.hotelgroup.com/filerepo/appdynamics/machineagent.zip"
         source "https://s3-us-west-2.amazonaws.com/aws-team/430864_anita/machineagent-bundle-64bit-linux-4.1.1.2.zip"
         mode 00777
    end
end


bash 'setup_appdynamics' do
     code <<-EOF

        echo "Checking if AppDynamics install.dir exists: #{node['APPDYN_HOME']}" >>/tmp/chefprovisioning.log

        if [ ! -d "#{node['APPDYN_HOME']}" ]; then
            mkdir -p #{node['APPDYN_HOME']}
            echo "Creating AppDynamics install.dir: #{node['APPDYN_HOME']}" >>/tmp/chefprovisioning.log
        fi;

        if [ ! -d "#{node['APPDYN_HOME']}/appserveragent/" ]; then
            echo "Extracting AppDynamics:AppServer Agent..." >>/tmp/chefprovisioning.log
            /usr/bin/unzip #{temp}/appserveragent.zip -d #{node['APPDYN_HOME']}/appserveragent/
            echo "AppServer Agent Extracted to location: #{node['APPDYN_HOME']}/appserveragent" >>/tmp/chefprovisioning.log
        else
            echo "AppDynamics appserveragent.zip already deployed. Will not overwrite" >>/tmp/chefprovisioning.log
        fi;
        if [ ! -d "#{temp}/machineagent/" ]; then
            /usr/bin/unzip #{temp}/machineagent.zip -d #{node['APPDYN_HOME']}/machineagent/
            echo "machine agent not available" >> /tmp/chefprovisioning.log
        else
            echo "AppDynamics machineagent.zip already deployed. Will not overwrite" >>/tmp/chefprovisioning.log
        fi;
        EOF
end

template '/opt/appdynamics/appserveragent/conf/controller-info.xml' do
	source 'appserver-controller-info.xml.erb'
	mode 0644
	owner 'root'
	group 'root'
end

template '/opt/appdynamics/appserveragent/ver4.1.1.2/conf/controller-info.xml' do
	source 'appserver-controller-info.xml.erb'
	mode 0644
	owner 'root'
	group 'root'
end
template '/opt/appdynamics/machineagent/conf/controller-info.xml' do
	source 'machine-controller-info.xml.erb'
	mode 0644
	owner 'root'
	group 'root'
end

bash 'start_jar_appdynamics' do
     code <<-EOF
        if [ `ps aux | grep [m]achineagent | wc -l` -lt 1 ]; then 
            nohup java -jar #{node['APPDYN_HOME']}/machineagent/machineagent.jar 1>>#{node['APPDYN_HOME']}/appdynamics.log 2>&1 &
            echo "AppDynamics machineagent started on VM" >>/tmp/chefprovisioning.log
        else
            echo "AppDynamics machineagent already running, will not restart" >>/tmp/chefprovisioning.log
        fi;
        EOF
end
