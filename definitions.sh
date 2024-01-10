#!/bin/bash
SITE_NAME=myhomepage
DEFAULT_USER=vagrant
DEFAULT_USER_HOME_DIR=$(grep "${DEFAULT_USER}" /etc/passwd | cut -d ":" -f6)