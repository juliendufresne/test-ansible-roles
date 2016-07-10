#!/usr/bin/env bash

if which yum &>/dev/null
then
    yum install -y epel-release python-crypto
    yum reinstall -y python-crypto
    yum install -y ansible
fi
