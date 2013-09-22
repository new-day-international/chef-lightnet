package 'memcached'

# now make second instance of memcached for the test env

template "/etc/memcached-test.conf" do
  source 'memcached.conf.erb'
  variables({:port => 11212})
  mode 0644
end

template "/etc/init/memcached-test.conf" do
  source 'upstart-memcached.conf.erb'
  mode 0644
end

service 'memcached-test' do
  provider Chef::Provider::Service::Upstart
  action :start
end