#!/bin/bash
if [ "$EUID" -eq 0 ]; then
    echo "${BASH_SOURCE[0]} is expected to be run as non-root"
    exit 1
fi
source /vagrant/definitions.sh
mkdir -p "$HOME"/.bashrc.d
cp /vagrant/bashrc* "$HOME"/.bashrc.d
source "$HOME"/.bashrc
cd /var/www/html || exit
composer create-project drupal/recommended-project "${SITE_NAME}" -n
cd "${SITE_NAME}"/web/sites/default || exit
cp default.settings.php settings.php
mkdir files
