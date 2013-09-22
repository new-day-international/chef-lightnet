unless node['lsb']['id'] == 'Ubuntu' && node['lsb']['release'] == "12.04"
  Chef::Application.fatal!("Only Ubuntu 12.04 supported")
end

