package 'joe'

# python 'joe: enable nobackup' do
#   code <<-PYSCRIPT

# import re
# ff = open('/etc/joe/joerc', 'rb')
# new_contents = re.sub('  -nobackup', '-nobackup', ff.read())
# ff = open('/etc/joe/joerc', 'wb')
# ff.write(new_contents)

#   PYSCRIPT
# end

ruby_block 'joe: enable nobackup' do
  block do
    rc = Chef::Util::FileEdit.new('/etc/joe/joerc')
    rc.search_file_replace(
      /  -nobackup/,
      '-nobackup'
    )
    rc.write_file
  end
end

if node[:lightnet][:user] == 'vagrant'
  template '/home/vagrant/.bashrc' do
    source "bashrc.erb"
    mode 0644
    owner node[:lightnet][:user]
    group node[:lightnet][:group]
  end
end
