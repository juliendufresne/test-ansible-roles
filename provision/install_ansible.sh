#!/usr/bin/env bash

if which yum &>/dev/null
then
    sudo yum install -y epel-release python-crypto
    sudo yum reinstall -y python-crypto
    sudo yum install -y ansible
fi
