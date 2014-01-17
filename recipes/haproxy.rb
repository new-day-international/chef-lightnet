apt_package 'haproxy' do
  action :install
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
