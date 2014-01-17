bash "stop reddit-paster if running" do 
  code <<-BASH
initctl stop reddit-paster || true
  BASH
end

file "/etc/init/reddit-paster.conf" do
  action :delete
end

template "/etc/init/reddit-gunicorn.conf" do
  mode 0644
  owner 'root'
  group 'root'
end

service 'reddit-gunicorn' do
  provider Chef::Provider::Service::Upstart
  action :start
end
