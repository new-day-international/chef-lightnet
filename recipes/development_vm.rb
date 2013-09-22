include_recipe 'lightnet::make_myers_happy'

# TODO: make a queue runner recipe
# TODO: make patch to vagrant-aws to make ebs optimized instances
# TODO: make rake task to create/upload IAMs policy, keypair, create buckets, create cloudsearch instances, create SES privilages using fog
# TODO: start the right number of workers: esp the cloudsearch_q
# TODO: Script that setups the cloudsearch indexes
# TODO: Script that sets up the upload bucket.  
# <?xml version="1.0" encoding="UTF-8"?>
# <CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
#     <CORSRule>
#         <AllowedOrigin>*</AllowedOrigin>
#         <AllowedMethod>GET</AllowedMethod>
#         <MaxAgeSeconds>3000</MaxAgeSeconds>
#         <AllowedHeader>Authorization</AllowedHeader>
#     </CORSRule>
#     <CORSRule>
#         <AllowedOrigin>http://reddit.local:8080</AllowedOrigin>
#         <AllowedOrigin>http://test.lightnet.is</AllowedOrigin>
#         <AllowedMethod>POST</AllowedMethod>
#         <AllowedMethod>GET</AllowedMethod>
#         <MaxAgeSeconds>3000</MaxAgeSeconds>
#         <AllowedHeader>*</AllowedHeader>
#     </CORSRule>
# </CORSConfiguration>

include_recipe 'lightnet::reddit_package_repo'

include_recipe 'lightnet::postgresql_server'
include_recipe 'lightnet::rabbitmq_server'
include_recipe 'lightnet::memcached_server'
include_recipe 'lightnet::cassandra_server'

include_recipe 'lightnet::frontend_server'
