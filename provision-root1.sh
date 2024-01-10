#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "${BASH_SOURCE[0]} is expected to be run as root"
    exit 1
fi
source /vagrant/definitions.sh
cat /"${DEFAULT_USER}"/append-to-root-bashrc.sh >> "$HOME"/.bashrc
mkdir -p "$HOME"/.bashrc.d
cp /"${DEFAULT_USER}"/bashrc* "$HOME"/.bashrc.d
source "$HOME"/.bashrc
cp -r /home/"${DEFAULT_USER}"/.ssh "$HOME"
# dnf update
dnf module -y enable php:8.1
dnf install -y --setopt=tsflags=nodocs \
            nginx \
            nmap \
            php-fpm php-cli php-xml php-gd php-pdo php-opcache php-mbstring \
            mysql-server \
            unzip
# dnf clean all

# NGINX
usermod -a -G nginx "${DEFAULT_USER}"
chown -R "${DEFAULT_USER}":nginx /var/www/html
sed "s/<my_site_name>/${SITE_NAME}/g" /vagrant/nginx.conf-template > /etc/nginx/nginx.conf
systemctl enable nginx

# PHP
sed -i "s/user = apache/user = nginx/" /etc/php-fpm.d/www.conf
sed -i "s/group = apache/group = nginx/" /etc/php-fpm.d/www.conf

# MySQL
systemctl enable mysqld.service
# mysql_secure_installation

# Composer
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
HASH=$(curl -sS https://composer.github.io/installer.sig)
php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
