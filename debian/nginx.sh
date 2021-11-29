#!/bin/bash

apt-get -y install nginx

mv /etc/nginx/nginx.conf /etc/nginx/NGINX.BACK

tee /etc/nginx/nginx.conf <<-'EOF'
user www-data;
worker_processes auto;
error_log  /var/log/nginx/error.log warn;
pid /run/nginx.pid;
worker_rlimit_nofile 65535;
include /etc/nginx/modules-enabled/*.conf;
events{
  use epoll;
  worker_connections 65535;
}

http{
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;
  sendfile on;
  tcp_nopush on;
  types_hash_max_size 2048;
  client_header_timeout 15;
  client_body_timeout 15;
  client_max_body_size 50m;
  send_timeout    600;
  keepalive_timeout 60;
  server_tokens off;
  gzip on;
  gzip_min_length  1k;
  gzip_buffers     4 16k;
  gzip_http_version 1.0;
  gzip_comp_level 2;
  gzip_types       text/plain application/x-javascript text/css application/xml;
  gzip_vary on;
  gzip_disable msie6;
  log_format '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';
  include /etc/nginx/conf.d/*;
}
EOF


tee /etc/nginx/conf.d/default.conf <<-'EOF'
server {
    server_name _;
    listen 80 default_server;
    #listen 443 ssl default_server;

    ## To also support IPv6, uncomment this block
    # listen [::]:80 default_server;
    # listen [::]:443 ssl default_server;

    #ssl_certificate <path to cert>;
    #ssl_certificate_key <path to key>;
    return 444; # or whatever
}
EOF

systemctl start nginx.service
systemctl enable nginx.service
systemctl stop nginx.service


