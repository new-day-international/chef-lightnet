package 'joe'

ruby_block 'make joe not leave backup files' do
  block do
    rc = Chef::Util::FileEdit.new("/etc/joe/joerc")
    rc.search_file_replace(/^ -nobackups/, '-nobackups')
    rc.write_file
  end
end
