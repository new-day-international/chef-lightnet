group node[:lightnet][:group]

user node[:lightnet][:user] do
  comment 'reddit user'
  system true
  shell '/bin/false'
end

packages = %w(
  git-core

  python-dev
  python-setuptools
  python-routes
  python-pylons
  python-boto
  python-tz
  python-crypto
  python-babel
  cython
  python-sqlalchemy
  python-beautifulsoup
  python-cssutils
  python-chardet
  python-psycopg2
  python-pycountry
  python-pycassa
  python-imaging
  python-pycaptcha
  python-amqplib
  python-pylibmc
  python-bcrypt
  python-snudown
  python-l2cs
  python-lxml
  python-zope.interface
  python-kazoo
  python-stripe

  nodejs
  gettext
  make
  optipng
  jpegoptim

  postgresql-client
  haproxy
)

packages.each do |package_name|
  apt_package package_name do
    action :install
  end
end



# ###############################################################################
# # Wait for all the services to be up
# ###############################################################################
# # cassandra no longer auto-starts
# service cassandra start

# # check each port for connectivity
# echo "Waiting for services to be available, see source for port meanings..."
# # 11211 - memcache
# # 5432 - postgres
# # 5672 - rabbitmq
# # 9160 - cassandra
# for port in 11211 5432 5672 9160; do
#     while ! nc -vz localhost $port; do
#         sleep 1
#     done
# done
# TODO: why do I need to create the shared dir by hand?

directory node[:lightnet][:application_directory] do
  user node[:lightnet][:user]
  group node[:lightnet][:group]
end

git "#{node[:lightnet][:application_directory]}/reddit" do 
  repo 'https://github.com/new-day-international/reddit.git'
  user node[:lightnet][:user]
  group node[:lightnet][:group]
end


# TODO make production branch for i18n
git "#{node[:lightnet][:application_directory]}/reddit-i18n" do 
  repo 'https://github.com/new-day-international/reddit-i18n.git'
  user node[:lightnet][:user]
  group node[:lightnet][:group]
end

# execute "create reddit cassandra keyspace" do
#   command 'echo "create keyspace reddit;" | cassandra-cli -h localhost -B'
#   only_if 'cassandra-cli -h localhost -k reddit &> /dev/null'
# end


# bash "cassandra: setup reddit keyspace and peramcache column family" do
#   code <<-EOH
# if ! echo | cassandra-cli -h localhost -k reddit &> /dev/null; then
#     echo "create keyspace reddit;" | cassandra-cli -h localhost -B
# fi

# cat <<CASS | cassandra-cli -B -h localhost -k reddit || true
# create column family permacache with column_type = 'Standard' and
#                                      comparator = 'BytesType';
# CASS
#   EOH
# end


# ###############################################################################
# # Configure Cassandra
# ###############################################################################
# if ! echo | cassandra-cli -h localhost -k reddit &> /dev/null; then
#     echo "create keyspace reddit;" | cassandra-cli -h localhost -B
# fi

# cat <<CASS | cassandra-cli -B -h localhost -k reddit || true
# create column family permacache with column_type = 'Standard' and
#                                      comparator = 'BytesType';
# CASS




# ###############################################################################
# # Configure PostgreSQL
# ###############################################################################
bash "postgresql: create database and import functions" do 
  code <<-EOH

SQL="SELECT COUNT(1) FROM pg_catalog.pg_database WHERE datname = '#{node[:lightnet][:postgres_database]}';"
IS_DATABASE_CREATED=$(sudo -u postgres psql -t -c "$SQL")

if [ $IS_DATABASE_CREATED -ne 1 ]; then
    cat <<PGSCRIPT | sudo -u postgres psql
CREATE DATABASE #{node[:lightnet][:postgres_database]} WITH ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE template0;
CREATE USER #{node[:lightnet][:postgres_user]} WITH PASSWORD '#{node[:lightnet][:postgres_password]}';
PGSCRIPT
fi

sudo -u postgres psql #{node[:lightnet][:postgres_user]} < #{node[:lightnet][:application_directory]}/reddit/sql/functions.sql
  
  EOH
end

# ###############################################################################
# # Configure RabbitMQ
# ###############################################################################

bash "rabbitmq: create vhost and user" do 

  code <<-EOH

if ! rabbitmqctl list_vhosts | egrep "^#{node[:lightnet][:rabbitmq_vhost]}$"
then
    rabbitmqctl add_vhost #{node[:lightnet][:rabbitmq_vhost]}
fi

if ! rabbitmqctl list_users | egrep "^#{node[:lightnet][:rabbitmq_user]}"
then
    rabbitmqctl add_user #{node[:lightnet][:rabbitmq_user]} #{node[:lightnet][:rabbitmq_user]}
fi

rabbitmqctl set_permissions -p #{node[:lightnet][:rabbitmq_vhost]} #{node[:lightnet][:rabbitmq_user]} ".*" ".*" ".*"
  EOH
end

template "#{node[:lightnet][:application_directory]}/reddit/r2/development.update" do
  mode 0644
  owner node[:lightnet][:user]
  group node[:lightnet][:group]
end

template "#{node[:lightnet][:application_directory]}/r2/production.update" do
  mode 0644
  owner node[:lightnet][:user]
  group node[:lightnet][:group]
end

# ###############################################################################
# # Install and configure the reddit code
# ###############################################################################

bash "build reddit" do
  cwd "#{node[:lightnet][:application_directory]}/reddit/r2"
  code <<-EOH
sudo -u reddit python setup.py build
sudo -u reddit make pyx # generate the .c files from .pyx
python setup.py develop
  EOH
end

bash "build reddit-i18n" do
  cwd "#{node[:lightnet][:application_directory]}/reddit-i18n"
  code <<-EOH
sudo -u #{node[:lightnet][:user]} python setup.py build
python setup.py develop
sudo -u #{node[:lightnet][:user]} make
  EOH
end

bash "build reddit (part 2)" do
  cwd "#{node[:lightnet][:application_directory]}/reddit/r2"
  code <<-EOH
sudo -u #{node[:lightnet][:user]} make
sudo -u #{node[:lightnet][:user]} make ini
  EOH
end

link "#{node[:lightnet][:application_directory]}/reddit/r2/run.ini" do
  to "#{node[:lightnet][:application_directory]}/reddit/r2/development.ini"
end


ruby_block 'enable haproxy' do
  block do
    rc = Chef::Util::FileEdit.new("/etc/default/haproxy")
    rc.search_file_replace(/^ENABLED=0/, 'ENABLED=1')
    rc.write_file
  end
end

file "/etc/haproxy/haproxy.cfg" do
  content <<-HAPROXY
global
    maxconn 100

frontend frontend 0.0.0.0:80
    mode http
    timeout client 10000
    option forwardfor except 127.0.0.1
    option httpclose

    default_backend dynamic

backend dynamic
    mode http
    timeout connect 4000
    timeout server 30000
    timeout queue 60000
    balance roundrobin

    server app01-8001 localhost:8001 maxconn 1
  HAPROXY
end

service "haproxy" do
  action :restart
end

ruby_block 'reddit: copy upstart files' do 
  block do
    ::FileUtils.cp(Dir.glob("#{node[:lightnet][:application_directory]}/reddit/upstart/*.conf"), '/etc/init')
  end
end

file "/etc/default/reddit" do
  content <<-DEFAULT
export REDDIT_ROOT=#{node[:lightnet][:application_directory]}/reddit/r2
export REDDIT_INI=#{node[:lightnet][:application_directory]}/reddit/r2/run.ini
export REDDIT_USER=#{node[:lightnet][:user]}
export REDDIT_GROUP=#{node[:lightnet][:group]}
export REDDIT_CONSUMER_CONFIG=#{node[:lightnet][:application_directory]}/consumer-count.d
alias wrap-job=#{node[:lightnet][:application_directory]}/reddit/scripts/wrap-job
alias manage-consumers=#{node[:lightnet][:application_directory]}/reddit/scripts/manage-consumers
  DEFAULT
end

directory "#{node[:lightnet][:application_directory]}/consumer-count.d" do
  user node[:lightnet][:user]
  group node[:lightnet][:group]
end

def set_consumer_count(filename, count)
  file "#{node[:lightnet][:application_directory]}/consumer-count.d/#{filename}" do
    content "#{count}"
  user node[:lightnet][:user]
  group node[:lightnet][:group]
  end
end

set_consumer_count 'log_q', 0
set_consumer_count 'cloudsearch_q', 0
set_consumer_count 'scraper_q', 0
set_consumer_count 'commentstree_q', 1
set_consumer_count 'newcomments_q', 1
set_consumer_count 'vote_link_q', 1
set_consumer_count 'vote_comment_q', 1
set_consumer_count 'summary_email_q', 1

bash "reddit: start" do 
  code "initctl emit reddit-restart"
end

template "/etc/cron.d/reddit" do
  source "reddit.cron.erb"
  mode 0644
  owner "reddit"
  group "nogroup"
end

if false
  bash do
    code <<-BASH

cd #{node[:lightnet][:application_directory]}/reddit/r2
sudo -u #{node[:lightnet][:user]} paster run run.ini r2/models/populatedb.py -c 'populate()'
initctl start reddit-job-update_reddits

    BASH
  end
end

