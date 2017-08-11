#
# Cookbook:: artboss
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


# install zip
apt_package 'zip' do
  action :install
  only_if "apt-cache policy zip | grep -e 'Installed: (none)'"
end

# install java
apt_package 'default-jdk' do
  action :install
  only_if "apt-cache policy default-jdk | grep -e 'Installed: (none)'"
end


# download JBOSS
remote_file "#{Chef::Config[:file_cache_path]}/jboss-as-7.1.1.Final.zip" do
  source node[:artboss][:wgeturl]
  action :create_if_missing
end

# unzip JBOSS, skip if exists
bash 'unpack_jboss' do
  code <<-EOH
  sudo unzip "#{Chef::Config[:file_cache_path]}/jboss-as-7.1.1.Final.zip" -d #{node[:artboss][:installdir]} 
  EOH
  not_if { File.exist?("#{node[:artboss][:installdir]}/#{node[:artboss][:jbossdir]}/bin/standalone.sh") }
end


# download the app
remote_file "#{Chef::Config[:file_cache_path]}/master.zip" do
  source node[:artboss][:appurl]
  action :create_if_missing
end

# unpack the app, skip if exists
bash 'unpack_app' do
  code <<-EOH
  sudo unzip "#{Chef::Config[:file_cache_path]}/master.zip" -d #{node[:artboss][:installdir]}/#{node[:artboss][:jbossdir]}/standalone/deployments/
  EOH
  not_if { File.exist?("#{node[:artboss][:installdir]}/#{node[:artboss][:jbossdir]}/standalone/deployments/hello-world-war-master/dist/hello-world.war") }
end


# add deploy marker, skip if applied
bash 'app_dodeploy' do
  code <<-EOH
  cd #{node[:artboss][:installdir]}/#{node[:artboss][:jbossdir]}/standalone/deployments/hello-world-war-master/dist/
  touch hello-world.war.dodeploy
  EOH
  not_if { File.exist?("#{node[:artboss][:installdir]}/#{node[:artboss][:jbossdir]}/standalone/deployments/hello-world-war-master/dist/hello-world.war.deployed") }
end

# create user for JBOSS service
user node[:artboss][:user] do
  action :create
  system true
  shell "/bin/false"
  not_if "id -u #{node[:artboss][:user]}"
end

# get service config
cookbook_file '/etc/init.d/jboss-as' do
  source 'jboss-as'
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
end

# change jboss dir owner
execute "ch_owner" do
  command "sudo chown -R #{node[:artboss][:jbossowner]} #{node[:artboss][:installdir]}/#{node[:artboss][:jbossdir]}/"
  not_if "stat #{node[:artboss][:installdir]}/#{node[:artboss][:jbossdir]}/ | grep -e '#{node[:artboss][:jbossowner]}.*#{node[:artboss][:jbossowner]}'"
end

# run jboss service and auto deploy apps
execute "run_service_step" do
  command "/etc/init.d/jboss-as start"
  not_if "curl localhost:8080/hello-world/ | grep -e '<title>Hello World!</title>'"
end

# check app running
execute "check_the_app" do
  command "echo FATAL_APP_INIT_FAILURE"
  retries 3
  not_if "curl localhost:8080/hello-world/ | grep -e '<title>Hello World!</title>'"
end
