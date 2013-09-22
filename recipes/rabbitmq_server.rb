#package 'rabbitmq-server'

include_recipe 'rabbitmq'
include_recipe 'rabbitmq::mgmt_console'

rabbitmq_vhost node[:lightnet][:rabbitmq_vhost] do
  action :add
end
rabbitmq_user node[:lightnet][:rabbitmq_user] do
  action :add
  password node[:lightnet][:rabbitmq_password]
end
rabbitmq_user node[:lightnet][:rabbitmq_user] do
  action :set_permissions
  vhost node[:lightnet][:rabbitmq_vhost]
  permissions ".* .* .*"
end

rabbitmq_vhost node[:lightnet][:test][:rabbitmq_vhost] do
  action :add
end
rabbitmq_user node[:lightnet][:test][:rabbitmq_user] do
  action :add
  password node[:lightnet][:test][:rabbitmq_password]
end
rabbitmq_user node[:lightnet][:test][:rabbitmq_user] do
  action :set_permissions
  vhost node[:lightnet][:test][:rabbitmq_vhost]
  permissions ".* .* .*"
end
