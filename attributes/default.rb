default[:lightnet][:environment_type] = 'development'

default[:lightnet][:domain_name] = 'localdev.lightnetb.org'
default[:lightnet][:system_user] = 'lightnet'
default[:lightnet][:admins] = ['Alice_Admin_1']
default[:lightnet][:initial_space_subscriptions] = ['welcome', 'connector', 'newspaces', 'feedback', 'lightnet.help', 'lightnet.news', 'lightnet.bugs', 'links']
default[:lightnet][:automatic_reddits] = ['links']
default[:lightnet][:default_space] = 'lightnet'

default[:lightnet][:create_user] = true
default[:lightnet][:user] = "reddit"
default[:lightnet][:group] = "nogroup"

default[:lightnet][:github_locations][:reddit] = "new-day-international/reddit"
default[:lightnet][:github_locations][:'reddit-i18n'] = "new-day-international/reddit-i18n"
default[:lightnet][:github_locations][:snudown] = "new-day-international/snudown"

default[:lightnet][:application_directory] = "/home/reddit"
default[:lightnet][:scratch_directory] = "/home/reddit"

default[:lightnet][:postgres_user] = "reddit"
default[:lightnet][:postgres_password] = "password"
default[:lightnet][:postgres_database] = "reddit"

default[:lightnet][:cassandra_keyspace] = "reddit"
default[:lightnet][:cassandra][:max_heap_size] = "738M"
default[:lightnet][:cassandra][:heap_newsize] = "100M"

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
