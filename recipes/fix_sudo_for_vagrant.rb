node.set['authorization']['sudo']['sudoers_defaults'] = [
  'exempt_group=sudo',
  'env_reset',
  'secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"',
]
node.set['authorization']['sudo']['include_sudoers_d'] = true

include_recipe 'sudo'

sudo 'sudo-group' do 
  group 'sudo'
  nopasswd true
end

group "sudo" do
  action :modify
  members "vagrant"
  append true
end