package 'joe'

python 'joe: enable nobackup' do
  code <<-PYSCRIPT

import re
ff = open('/etc/joe/joerc', 'rb')
new_contents = re.sub('  -nobackup', '-nobackup', ff.read())
ff = open('/etc/joe/joerc', 'wb')
ff.write(new_contents)

  PYSCRIPT
end

if node[:lightnet][:user] == 'vagrant'
  template '/home/vagrant/.bashrc' do
    source "bashrc.erb"
    mode 0644
    owner node[:lightnet][:user]
    group node[:lightnet][:group]
  end
end
