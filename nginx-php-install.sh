#!/bin/sh
#this is tested on fresh 2016-09-23-raspbian-jessie-lite.img
#sudo su
#apt-get update -y && apt-get upgrade -y && apt-get install git -y
#git clone https://github.com/catonrug/nginx-php-virtual-hosts-raspbian-jessie.git && cd nginx-php-virtual-hosts-raspbian-jessie && chmod +x nginx-php-install.sh
#./nginx-php-install.sh


#install nginx
apt-get install nginx -y

#check nginx status
service nginx status

#if knginx is not active then start it
service nginx start

#go to site thought port 80
wget -qO- http://localhost | sed -e "s/<[^>]*>//g"

#install php support for nginx by installing php5-fpm package
#fpm stands for FastCGI Process Manager. https://php-fpm.org/
apt-get install php5-fpm -y

#check the status of service
service php5-fpm status

#check of there is any virtual hosts before
ls -l /etc/nginx/sites-available

#set up virtual host [wp.nginx]
cat > /etc/nginx/sites-available/wp.nginx << EOF
server {
server_name wp.nginx;
listen 80;
root /var/www/wp.nginx/;
access_log /var/log/nginx/wp.nginx.com-access.log;
error_log /var/log/nginx/wp.nginx-error.log;
index index.php index.html index.htm;
location ~ \.php {
fastcgi_split_path_info ^(.+\.php)(/.+)$;
fastcgi_pass unix:/var/run/php5-fpm.sock;
fastcgi_index index.php;
include fastcgi.conf;
}
}
EOF

#once I use [fastcgi_split_path_info ^(.+.php)(/.+)$;] in nginx config I have to enable it in php.ini
sed -i "s/^.*cgi\.fix_pathinfo=.*$/cgi\.fix_pathinfo=1/" /etc/php5/fpm/php.ini

#make symbolic limk
ln -s /etc/nginx/sites-available/wp.nginx /etc/nginx/sites-enabled/wp.nginx

#create directory for web page
mkdir -p /var/www/wp.nginx

#create php sample file
echo "<?php phpinfo(); ?>" > /var/www/wp.nginx/index.php

#restart config file for php and nginx
/etc/init.d/php5-fpm reload && /etc/init.d/nginx reload

#all credits to
#https://www.raspberrypi.org/documentation/remote-access/web-server/nginx.md
#https://www.stewright.me/2014/06/tutorial-install-nginx-and-php-on-raspbian/
