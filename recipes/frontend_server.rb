group node[:lightnet][:group]

if node[:lightnet][:create_user]
  user node[:lightnet][:user] do
    comment 'reddit user'
    system true
    shell "/bin/false"
  end
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
  python-l2cs
  python-lxml
  python-zope.interface
  python-kazoo
  python-stripe
  python-pip
  
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

git "#{node[:lightnet][:application_directory]}/snudown" do 
  repo 'https://github.com/new-day-international/snudown.git'
  user node[:lightnet][:user]
  group node[:lightnet][:group]
end

# ###############################################################################
# # Configure PostgreSQL
# ###############################################################################
bash "postgresql: import functions" do 
  code <<-EOH
sudo -u postgres psql #{node[:lightnet][:postgres_database]} < #{node[:lightnet][:application_directory]}/reddit/sql/functions.sql
sudo -u postgres psql #{node[:lightnet][:test][:postgres_database]} < #{node[:lightnet][:application_directory]}/reddit/sql/functions.sql
  EOH
end

template "#{node[:lightnet][:application_directory]}/reddit/r2/development.update" do
  mode 0644
  owner node[:lightnet][:user]
  group node[:lightnet][:group]
end

template "#{node[:lightnet][:application_directory]}/reddit/r2/test.update" do
  mode 0644
  owner node[:lightnet][:user]
  group node[:lightnet][:group]
end

template "#{node[:lightnet][:application_directory]}/reddit/r2/production.update" do
  mode 0644
  owner node[:lightnet][:user]
  group node[:lightnet][:group]
end

# ###############################################################################
# # Install and configure the reddit code
# ###############################################################################

bash "build snudown" do
  cwd "#{node[:lightnet][:application_directory]}/snudown"
  code <<-EOH
sudo -u #{node[:lightnet][:user]} python setup.py build
python setup.py develop
  EOH
end

bash "build reddit" do
  cwd "#{node[:lightnet][:application_directory]}/reddit/r2"
  code <<-EOH
sudo -u #{node[:lightnet][:user]} python setup.py build
sudo -u #{node[:lightnet][:user]} make pyx # generate the .c files from .pyx
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

bash "reddit: setup env" do
  cwd "#{node[:lightnet][:application_directory]}/reddit"
  code <<-BASH
./scripts/create_env.py r2/development.ini
./scripts/create_env.py r2/test.ini
  BASH
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

template "/etc/default/reddit" do
  source "reddit-default.erb"
  mode 0644
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
  code <<-BASH
initctl emit reddit-stop || true
initctl emit reddit-start
  BASH
end

template "/etc/cron.d/reddit" do
  source "reddit.cron.erb"
  mode 0644
end

python_pip 'mock' do
  action :install
end

python_pip 'nosexcover' do
  action :install
end

python_pip 'pylint' do
  action :install
end

python_pip 'raven' do
  action :install
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

