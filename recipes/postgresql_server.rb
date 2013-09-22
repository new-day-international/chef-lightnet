#package 'postgresql'

# The Reddit PPA has a package for postgresql 9.0 that makes it hard to use 9.1
# Because of bugs in the postgresql cookbook you can't 
# just specify the version
node.set[:postgresql][:version] = "9.0"
node.set[:postgresql][:server][:packages] = ['postgresql']
node.set[:postgresql][:dir] = "/etc/postgresql/#{node['postgresql']['version']}/main"
node.set[:postgresql][:config][:data_directory] = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
node.set[:postgresql][:config][:hba_file] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
node.set[:postgresql][:config][:ident_file] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
node.set[:postgresql][:config][:external_pid_file] = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"

include_recipe 'postgresql::client'
include_recipe 'postgresql::server'

include_recipe 'database::postgresql'

# package 'libpq-dev'

# chef_gem "pg" do
#   action :install
# end

postgresql_database_user node[:lightnet][:postgres_user] do
  connection :host => "127.0.0.1", :port => 5432, :username => 'postgres', :password => node['postgresql']['password']['postgres']
  password node[:lightnet][:postgres_password]
end

postgresql_database node[:lightnet][:postgres_database] do
  connection :host => "127.0.0.1", :port => 5432, :username => 'postgres', :password => node['postgresql']['password']['postgres']
  owner node[:lightnet][:postgres_user]
  action :create
end

postgresql_database_user node[:lightnet][:test][:postgres_user] do
  connection :host => "127.0.0.1", :port => 5432, :username => 'postgres', :password => node['postgresql']['password']['postgres']
  password node[:lightnet][:test][:postgres_password]
end

postgresql_database node[:lightnet][:test][:postgres_database] do
  connection :host => "127.0.0.1", :port => 5432, :username => 'postgres', :password => node['postgresql']['password']['postgres']
  owner node[:lightnet][:test][:postgres_user]
  action :create
end

