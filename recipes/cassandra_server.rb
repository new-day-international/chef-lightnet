# not using the Cassandra cookbook, because it's too different from what we have
# and I looks too complex

package 'java-common'

include_recipe 'java::oracle'

package 'libjna-java'

package 'cassandra'

template '/etc/cassandra/cassandra-env.sh' do
  mode 0644
end

service 'cassandra' do 
  action :start
  subscribes :restart, "template[/etc/cassandra/cassandra-env.sh]", :immediately
end
