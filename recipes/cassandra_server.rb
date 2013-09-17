# not using the Cassandra cookbook, because it's too different from what we have
# and I looks too complex

package 'java-common'

include_recipe 'java::oracle'

package 'libjna-java'

package 'cassandra'

ruby_block 'Fix per thread stack for cassandra' do
  block do
    rc = Chef::Util::FileEdit.new('/etc/cassandra/cassandra-env.sh')
    rc.search_file_replace(
      /-Xss128k/,
      '-Xss160k'
    )
    rc.write_file
  end
end

service 'cassandra' do 
  action :start
end
