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

        --ansible-role ANSIBLE_ROLE     use specified ansible role instead of default one. This option may be specified
                                        multiple times.
        --config-file CONFIG_FILE       use specified configuration file.
                                        CONFIG_FILE must end with .md
                                        The file path may be relative to:
                                        - the current working directory
                                        - this project root directory
                                        - this project config directory
                                        To ease usage, you can omit file directory and extension.
                                        e.g: '--config-file default' may be resolved with <repository_root>/config/default.md
        --enable-vbguest                enable the vagrant-vbguest plugin and install it if needed.
        -h, --help                      show this help.
        --pre-script PRE_SCRIPT         path to a script to run before running ansible playbook.
        -v, --verbose                   increase verbosity.
        --vagrant-box VAGRANT_BOX       use specified vagrant box instead of default one. This option may be specified multiple times.
"
}
