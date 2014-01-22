apt_package 'haproxy' do
  action :purge
end

file "/etc/haproxy/haproxy.cfg" do
  action :delete
end

#### Decided that we'll just go with the Ubuntu 12.04 nginx for nowrecipes/haproxy.rb
# apt_repository "nginx" do
#   uri "http://nginx.org/packages/ubuntu/"
#   distribution node['lsb']['codename']
#   components ["nginx"]
#   key "http://nginx.org/keys/nginx_signing.key"
#   cache_rebuild true
# end
# file "/etc/nginx/conf.d/default.conf" do
#   action :delete
# end
# file "/etc/nginx/conf.d/example_ssl.conf" do
#   action :delete
# end
# template "/etc/nginx/conf.d/lightnet.conf" do
#   source "nginx-lightnet.erb"
#   mode 0644
# end

apt_package 'nginx' do
  action :install
end

template "/etc/nginx/sites-available/lightnet" do
  source "nginx-lightnet.erb"
  mode 0644
end

file "/etc/nginx/sites-enabled/default" do
  action :delete
end

link "/etc/nginx/sites-enabled/lightnet" do
  to "/etc/nginx/sites-available/lightnet"
end

service "nginx" do
  action :restart
end
