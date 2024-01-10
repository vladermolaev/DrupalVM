#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "${BASH_SOURCE[0]} is expected to be run as root"
    exit 1
fi
source /vagrant/definitions.sh
chown -R "${DEFAULT_USER}":nginx /var/www/html
chcon -R -t httpd_sys_content_rw_t /var/www/html/"${SITE_NAME}"/web/sites/default/files/
systemctl start nginx