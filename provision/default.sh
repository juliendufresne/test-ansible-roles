#!/usr/bin/env bash

set -e

which lsb_release &>/dev/null && INSTALL_LSB_RELEASE=false || INSTALL_LSB_RELEASE=true

if which apt-get &>/dev/null # Debian / Ubuntu
then
    sudo apt-get update
    sudo apt-get install -y libssl-dev libffi-dev build-essential python-dev python-crypto ca-certificates
    ${INSTALL_LSB_RELEASE} && { sudo apt-get install -y lsb-release; }
elif which yum &>/dev/null # RHEL
then
    sudo yum install -y gcc libffi-devel python-devel openssl-devel
    ${INSTALL_LSB_RELEASE} && { sudo yum install -y redhat-lsb; }
elif which pacman &>/dev/null #Archlinux
then
    sudo pacman -S ansible --noconfirm
fi

wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python
sudo easy_install urllib3 pyopenssl ndg-httpsclient pyasn1 pip
# ansible-galaxy does not work on latest ansible version for ubuntu 14.04
sudo pip install ansible==2.0.2.0
sudo ansible-galaxy install -vvvv -r /vagrant/requirements.yml
sudo pip install --upgrade Jinja2 ansible

if which apt-get &>/dev/null # Debian / Ubuntu
then
    sudo apt-get install -y --reinstall python-crypto
elif which yum &>/dev/null # RHEL
then
    sudo yum reinstall -y python-crypto
fi

echo "Python version: "$(python --version 2>&1 | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+")
echo "Ansible version: "$(ansible --version)
