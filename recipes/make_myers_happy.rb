package 'joe'

# joerc has some utf-8 unfriendly bytes in it, so trying to do this with 
# ruby hasn't worked
python 'joe: enable nobackup' do
  code <<-PYSCRIPT

import re
ff = open('/etc/joe/joerc', 'rb')
new_contents = re.sub('\s+-nobackup', '-nobackup', ff.read())
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
