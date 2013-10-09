default[:lightnet][:environment_type] = 'development'

default[:lightnet][:create_user] = true
default[:lightnet][:user] = "reddit"
default[:lightnet][:group] = "nogroup"

default[:lightnet][:application_directory] = "/home/reddit"
default[:lightnet][:scratch_directory] = "/home/reddit"

default[:lightnet][:postgres_user] = "reddit"
default[:lightnet][:postgres_password] = "password"
default[:lightnet][:postgres_database] = "reddit"

default[:lightnet][:cassandra_keyspace] = "reddit"
if node[:lightnet][:environment_type] == 'development'
  default[:lightnet][:cassandra][:max_heap_size] = "738M"
  default[:lightnet][:cassandra][:heap_newsize] = "100M"
else
  default[:lightnet][:cassandra][:max_heap_size] = nil
  default[:lightnet][:cassandra][:heap_newsize] = nil

end

default[:lightnet][:rabbitmq_vhost] = "/reddit"
default[:lightnet][:rabbitmq_user] = "reddit"
default[:lightnet][:rabbitmq_password] = "reddit"

default[:lightnet][:test][:postgres_user] = "reddit"
default[:lightnet][:test][:postgres_password] = "password"
default[:lightnet][:test][:postgres_database] = "reddit_test"

default[:lightnet][:test][:cassandra_keyspace] = "reddit_test"

default[:lightnet][:test][:rabbitmq_vhost] = "/reddit_test"
default[:lightnet][:test][:rabbitmq_user] = "reddit_test"
default[:lightnet][:test][:rabbitmq_password] = "reddit_test"
