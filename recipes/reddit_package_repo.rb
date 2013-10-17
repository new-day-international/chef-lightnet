apt_preference 'reddit' do
  package_name '*'
  pin          'release o=LP-PPA-reddit'
  pin_priority '600'
end

apt_repository "reddit" do
  uri "http://ppa.launchpad.net/reddit/ppa/ubuntu"
  distribution node['lsb']['codename']
  components ["main"]
  # why this keyserver? https://bugs.launchpad.net/ubuntu-website/+bug/435193
  keyserver "pool.sks-keyservers.net"
  key "65506D27"
  cache_rebuild true
end
