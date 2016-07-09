#!/usr/bin/env bash

resolve_config_file() {
    local current_option_value="$1"
    local previously_defined_value="$2"
    local repository_directory="$3"

    if [ -z "${current_option_value}" ]
    then
        error "Argument is required for the --config-file option"
        usage
        exit 1
    fi

    if [ -n "${previously_defined_value}" ]
    then
        error "You can not specify multiple configuration files"
        usage
        exit 1
    fi

    if [ "${current_option_value: -3}" != ".md" ]
    then
        current_option_value="${current_option_value}.md"
    fi

    if [ ! -f "${current_option_value}" ] && [ "/" == "${current_option_value:0:1}" ]
    then
        error "Unable to find configuration file ${current_option_value}"
        usage
        exit 1
    fi

    if [ -f "${current_option_value}" ]
    then
        current_option_value=$(readlink -m ${current_option_value})
    elif [ -f "${repository_directory}/${current_option_value}" ]
    then
        current_option_value="${repository_directory}/${current_option_value}"
    elif [ -f "${repository_directory}/config/${current_option_value}" ]
    then
        current_option_value="${repository_directory}/config/${current_option_value}"
    else
        error "Unable to find configuration file ${current_option_value}"
        usage
        exit 1
    fi

    echo "${current_option_value}"
}
