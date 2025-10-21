#!/bin/bash
apt-get update -y
apt-get install -y nginx

systemctl start nginx
systemctl enable nginx

cat <<EOF > /etc/nginx/sites-available/default
upstream backend {
    server ${green_ip};
    server ${blue_ip} backup;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        proxy_pass http://backend;
        # When the primary (green) server fails, NGINX will automatically
        # route traffic to the next server in the upstream block (blue).
    }
}
EOF

systemctl restart nginx
