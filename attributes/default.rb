default[:lightnet][:user] = "reddit"
default[:lightnet][:group] = "nogroup"

default[:lightnet][:application_directory] = "/home/reddit"

default[:lightnet][:postgres_user] = "reddit"
default[:lightnet][:postgres_password] = "password"
default[:lightnet][:postgres_database] = "reddit"

default[:lightnet][:cassandra_keyspace] = "reddit"

default[:lightnet][:rabbitmq_vhost] = "/reddit"
default[:lightnet][:rabbitmq_user] = "reddit"

default[:lightnet][:test][:postgres_user] = "reddit_test"
default[:lightnet][:test][:postgres_password] = "password"
default[:lightnet][:test][:postgres_database] = "reddit_test"

default[:lightnet][:test][:cassandra_keyspace] = "reddit_test"

default[:lightnet][:test][:rabbitmq_vhost] = "/reddit_test"
default[:lightnet][:test][:rabbitmq_user] = "reddit"
