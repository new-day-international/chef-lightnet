# # aptitude configuration
# APTITUDE_OPTIONS="-y" # limit bandwidth: -o Acquire::http::Dl-Limit=100"
# export DEBIAN_FRONTEND=noninteractive

# # add the reddit ppa for some custom packages
# apt-get install $APTITUDE_OPTIONS python-software-properties
# apt-add-repository -y ppa:reddit/ppa

# These crazy ".run_action(:add)" are a way to get the ppa added to apt before
# the postgresql recipe downloads the postgresql packages to build pg gem
apt_repository "reddit" do
  uri "http://ppa.launchpad.net/reddit/ppa/ubuntu"
  distribution node['lsb']['codename']
  components ["main"]
  # https://bugs.launchpad.net/ubuntu-website/+bug/435193
  keyserver "pool.sks-keyservers.net"
  key "65506D27"
end.run_action(:add)

# # pin the ppa -- packages present in the ppa will take precedence over
# # ones in other repositories (unless further pinning is done)
# cat <<HERE > /etc/apt/preferences.d/reddit
# Package: *
# Pin: release o=LP-PPA-reddit
# Pin-Priority: 600
# HERE

file "/etc/apt/preferences.d/reddit" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  content <<-HERE
Package: *
Pin: release o=LP-PPA-reddit
Pin-Priority: 600
HERE
end.run_action(:create)

