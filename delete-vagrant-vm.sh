#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage:"
    echo "${BASH_SOURCE[0]} <VM name>"
    exit 1
fi
VBoxManage controlvm "$1" poweroff
VBoxManage unregistervm "$1" --delete
rm -rf ~/Vagrant/"$1"