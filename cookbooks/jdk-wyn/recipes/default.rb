#
# Cookbook Name:: jdk-wyn
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

temp=Chef::Config[:file_cache_path]

remote_file "#{temp}/jdk-7u55-linux-x64.rpm" do
    #source "http://vsvphxupoc02.hotelgroup.com/filerepo/jdk/jdk-7u55-linux-x64.rpm"
    source "https://s3-us-west-2.amazonaws.com/aws-team/430864_anita/jdk-7u55-linux-x64.rpm"
    mode 00777
end


bash 'install_jdk' do
     code <<-EOF
        if [ ! -f "/usr/bin/java" ]; then 
            echo "Installing JDK 7" >> /tmp/chefprovisioning.log
            rpm -ivh #{temp}/jdk-7u55-linux-x64.rpm
        else
            echo "JDK 7 already installed" >> /tmp/chefprovisioning.log
        fi;
     EOF
end

