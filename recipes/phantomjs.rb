# tar_extract '' do
#   target_dir '/usr/local'
#   creates '/usr/local/phantomjs-1.9.2-linux-x86_64/phantomjs'
# end



remote_file "#{Chef::Config[:file_cache_path]}/phantomjs-1.9.2-linux-x86_64.tar.bz2" do
  source "https://phantomjs.googlecode.com/files/phantomjs-1.9.2-linux-x86_64.tar.bz2"
  backup false
  action :create
end

execute "extract phantomjs-1.9.2-linux-x86_64.tar.bz2" do
  command "tar xfj '#{Chef::Config['file_cache_path']}/phantomjs-1.9.2-linux-x86_64.tar.bz2'"
  cwd '/usr/local'
  creates '/usr/local/phantomjs-1.9.2-linux-x86_64/phantomjs'
end

link "/usr/local/bin/phantomjs" do
  to "/usr/local/phantomjs-1.9.2-linux-x86_64/bin/phantomjs"
end
