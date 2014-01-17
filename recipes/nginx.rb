apt_package 'haproxy' do
  action :purge
end

file "/etc/haproxy/haproxy.cfg" do
  action :delete
end

#### Decided that we'll just go with the Ubuntu 12.04 nginx for nowrecipes/haproxy.rb
# apt_repository "nginx" do
#   uri "http://nginx.org/packages/ubuntu/"
#   distribution node['lsb']['codename']
#   components ["nginx"]
#   key "http://nginx.org/keys/nginx_signing.key"
#   cache_rebuild true
# end

apt_package 'nginx' do
  action :install
end

file "/etc/nginx/sites-available/lightnet" do
  content <<-NGINX
upstream app_server {
    # server unix:/tmp/lightnet_gunicorn.sock fail_timeout=0;
    # For a TCP configuration:
    server 127.0.0.1:8001 fail_timeout=0;
}

server {
    #{"sendfile off;" if node[:lightnet][:environment_type] == 'development'}

    listen 80 default;
    client_max_body_size 4G;
    server_name _;

    keepalive_timeout 5;

    # path for static files
    root #{node[:lightnet][:application_directory]}/reddit/r2/r2/public;

    location / {
        # checks for static file, if not found proxy to app
        try_files $uri @proxy_to_app;
    }

    location @proxy_to_app {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;

        proxy_pass http://app_server;
    }

    error_page 500 502 503 504 /500.html;
    location = /500.html {
        root #{node[:lightnet][:application_directory]}/reddit/r2/r2/public;
    }
}
  NGINX
end

file "/etc/nginx/sites-enabled/default" do
  action :delete
end

link "/etc/nginx/sites-enabled/lightnet" do
  to "/etc/nginx/sites-available/lightnet"
end

service "nginx" do
  action :restart
end
