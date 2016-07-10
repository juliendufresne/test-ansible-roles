#!/usr/bin/env bash

CONFIG_FILE=
PRE_SCRIPT=
VAGRANT_BOXES=

resolve_config_file() {
    local current_option_value="$1"
    local repository_directory="${REPOSITORY_DIRECTORY}"

    if [ -z "${current_option_value}" ]
    then
        error "Argument is required for the --config-file option"
        usage
        exit 1
    fi

    if [ -n "${CONFIG_FILE}" ]
    then
        error "You can not specify multiple configuration files"
        usage
        exit 1
    fi

    if [ "${current_option_value: -3}" != ".md" ]
    then
        current_option_value="${current_option_value}.md"
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

    CONFIG_FILE="${current_option_value}"
}

resolve_pre_script() {
    local value="$1"

    if [ -n "${PRE_SCRIPT}" ]
    then
        error "You can not specify multiple values for option --pre-script"
        usage
        exit 1
    fi

    if [ -z "$value" ]
    then
        error "Argument is required for the --pre-script option"
        usage
        exit 1
    fi

    PRE_SCRIPT="$value"
}

resolve_vagrant_box() {
    local value="$1"

    if [ -z "${value}" ]
    then
        error "Argument is required for the --vagrant-box option"
        usage
        exit 1
    fi

    if [ -z "${VAGRANT_BOXES}" ]
    then
        VAGRANT_BOXES="${value}"
    else
        VAGRANT_BOXES="${VAGRANT_BOXES} ${value}"
    fi
}
