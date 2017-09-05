#
# Cookbook:: guacamole
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

if platform?('debian', 'ubuntu')

  # installs required dependencies
  package 'libcairo2-dev'
  if platform?('debian')
    package 'libjpeg62-turbo-dev'
  elsif
    package 'libjpeg-turbo8-dev'
  end
  package 'libpng-dev'
  package 'libossp-uuid-dev'

  # installs optional dependencies
  package 'libavcodec-dev'
  package 'libswscale-dev'
  package 'libavutil-dev'
  package 'libfreerdp-dev'
  package 'libpango1.0-dev'
  package 'libssh2-1-dev'
  package 'libtelnet-dev'
  package 'libvncserver-dev'
  package 'libpulse-dev'
  package 'libssl-dev'
  package 'libvorbis-dev'
  package 'libwebp-dev'

  # install java-jdk
  package 'openjdk-8-jdk-headless'

  # install tomcat
  package 'tomcat8'

  # install maven
  package 'maven'

  # Variables
  guac_version = node.default['guacamole']['server_version']

  # downloads the server source code
  remote_file "#{Chef::Config[:file_cache_path]}/guacamole-server-#{guac_version}.tar.gz" do
    source "http://apache.org/dyn/closer.cgi?action=download&filename=incubator/guacamole/#{guac_version}/source/guacamole-server-#{guac_version}.tar.gz"
    action :create_if_missing
    notifies :run, 'execute[extract_guacamole_server_tar_file]', :immediate
  end

  # extract the server from tar file
  execute 'extract_guacamole_server_tar_file' do
    command "tar xzvf guacamole-server-#{guac_version}.tar.gz"
    cwd Chef::Config[:file_cache_path].to_s
    action :nothing
  end

  # builds the server code
  bash 'build_guacamole_server' do
    cwd "#{Chef::Config[:file_cache_path]}/guacamole-server-#{guac_version}"
    code <<-EOH
      ./configure --with-init-dir=/etc/init.d
      make
      make install
      ldconfig
    EOH
  end

  # downloads the client source code
  war_file="#{Chef::Config[:file_cache_path]}/guacamole-client-#{guac_version}/guacamole/target/guacamole-#{guac_version}.war"

  remote_file "#{Chef::Config[:file_cache_path]}/guacamole-client-#{guac_version}.tar.gz" do
    source "http://apache.org/dyn/closer.cgi?action=download&filename=incubator/guacamole/#{guac_version}/source/guacamole-client-#{guac_version}.tar.gz"
    action :create_if_missing
    not_if { File.exist?(war_file) }
    notifies :run, 'execute[extract_guacamole_client_tar_file]', :immediate
  end

  # extract the client from tar file
  execute 'extract_guacamole_client_tar_file' do
    command "tar xzvf guacamole-client-#{guac_version}.tar.gz"
    cwd Chef::Config[:file_cache_path].to_s
    action :nothing
    notifies :run, 'execute[build client WAR file]', :immediate
  end

  # build the client WAR file
    execute 'build client WAR file' do
    command 'mvn package'
    cwd "#{Chef::Config[:file_cache_path]}/guacamole-client-#{guac_version}"
    action :nothing
  end

  # Deploying web app
  execute 'deploy guacamole client' do
    cwd "#{Chef::Config[:file_cache_path]}/guacamole-client-#{guac_version}"
    command "cp #{war_file} /var/lib/tomcat8/webapps/guacamole.war"
  end

  # Create configuration file
  directory '/etc/guacamole' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  template '/etc/guacamole/guacamole.properties' do
    source 'guacamole.properties.erb'
    owner 'root'
    group 'root'
    mode '0755'
  end

  template '/etc/guacamole/user-mapping.xml' do
    source 'user-mapping.xml.erb'
    owner 'tomcat8'
    group 'tomcat8'
    mode '0600'
  end

  if platform?('debian')
    directory '/var/lib/tomcat8/.guacamole' do
      owner 'root'
      group 'root'
      mode '0755'
      recursive true
      action :create
    end

    link '/var/lib/tomcat8/.guacamole/guacamole.properties' do
      to '/etc/guacamole/guacamole.properties'
      link_type :symbolic
    end
  elsif
    directory '/usr/share/tomcat8/.guacamole' do
      owner 'root'
      group 'root'
      mode '0755'
      recursive true
      action :create
    end

    link '/usr/share/tomcat8/.guacamole/guacamole.properties' do
      to '/etc/guacamole/guacamole.properties'
      link_type :symbolic
    end
  end

  # Tomcat Service
  service 'tomcat8' do
    action [:enable, :restart]
  end

  # Guacamole Service
  service 'guacd' do
    action [:enable, :restart]
  end
end
