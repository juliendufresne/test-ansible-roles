#!/usr/bin/env bash

set -e

which lsb_release &>/dev/null && INSTALL_LSB_RELEASE=false || INSTALL_LSB_RELEASE=true

if which apt-get &>/dev/null # Debian / Ubuntu
then
    sudo apt-get update
    ${INSTALL_LSB_RELEASE} && { sudo apt-get install -y lsb-release; }
elif which yum &>/dev/null # RHEL
then
    ${INSTALL_LSB_RELEASE} && { sudo yum install -y redhat-lsb; }
fi

exit 0
