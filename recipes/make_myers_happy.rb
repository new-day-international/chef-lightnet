package 'joe'

bash 'joe: enable nobackup' do
  code <<-BASH

ruby -pi.bak -e "gsub(/^ -nobackups/, '-nobackups')" /etc/joe/joerc

  BASH
end
