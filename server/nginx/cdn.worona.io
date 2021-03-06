# Expires map
map $sent_http_content_type $expires {
  default                       off;
  ~text/html                    epoch;
  ~application/json             epoch;
  ~text/css                     max;
  ~application/(x-)?javascript  max;
  ~image/                       max;
  ~application/octet-stream     max;
  ~application/.*font.*         max;
  ~font/                        max;
}

server {
  listen 443 ssl;
  listen 80;

  # SSL cert
  ssl_certificate /etc/nginx/ssl/nginx.crt;
  ssl_certificate_key /etc/nginx/ssl/nginx.key;

	# Disable SSLv3 (Poodle bug)
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

  server_name cdn.worona.io backend.worona.io direct.worona.io;

  # Cache
  expires $expires;

  location ~/api/v1/chcp/site/.+/index.html {
    alias /var/www/worona-cdn/packages/dist/core-app-worona/app/prod/html/cordova/index.html;
  }

  location /api {
    proxy_pass http://127.0.0.1:4500;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
  }

  merge_slashes off;

  location ~* ^/cors/(https?:/)(.*) {
    add_header 'cors' $1/$is_args$args;
    proxy_pass http://127.0.0.1:7779/$1$2$is_args$args;
  }

  location /packages/dist {
    alias /var/www/worona-cdn/packages/dist/;
  }
}
