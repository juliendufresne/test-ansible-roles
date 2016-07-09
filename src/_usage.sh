#!/usr/bin/env bash

usage() {
    local script_name="$1"

    if [ -z "${script_name}" ]
    then
        script_name=$0
    fi

    printf "\
\e[1mNAME\e[0m
       ${script_name} - Test ansible roles

\e[1mSYNOPSIS\e[0m
       ${script_name} [OPTION...]

\e[1mDESCRIPTION\e[0m
       Test ansible role in a vagrant box

        --ansible-role ANSIBLE_ROLE     use specified ansible role instead of default one. This option may be specified multiple times.
        -h, --help                      show this help.
        -v, --verbose                   increase verbosity.
        --vagrant-box VAGRANT_BOX       use specified vagrant box instead of default one. This option may be specified multiple times.
"
}
