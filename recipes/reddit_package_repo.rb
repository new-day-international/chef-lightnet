apt_preference 'reddit' do
  package_name '*'
  pin          'release o=LP-PPA-reddit'
  pin_priority '600'
end

apt_repository "reddit" do
  uri "http://ppa.launchpad.net/reddit/ppa/ubuntu"
  distribution node['lsb']['codename']
  components ["main"]
  # why did I put this in a gist rather pulling from a keyserver?  because they kept failing!
  key "https://gist.github.com/myers/7032130/raw"
  cache_rebuild true
end

log "Finished adding the reddit ppa to apt"