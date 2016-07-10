#!/usr/bin/env bash

REPOSITORY_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${REPOSITORY_DIRECTORY}/src/_lsb_release.sh"
. "${REPOSITORY_DIRECTORY}/src/_option_resolver.sh"
. "${REPOSITORY_DIRECTORY}/src/_print.sh"
. "${REPOSITORY_DIRECTORY}/src/_report.sh"
. "${REPOSITORY_DIRECTORY}/src/_result.sh"
. "${REPOSITORY_DIRECTORY}/src/_run.sh"
. "${REPOSITORY_DIRECTORY}/src/_usage.sh"

DEFAULT_ANSIBLE_ROLE="juliendufresne.influxdb"
DEFAULT_CONFIG_FILE="${REPOSITORY_DIRECTORY}/config/default.md"
DEFAULT_VAGRANT_BOX="geerlingguy/ubuntu1604"
IS_VERBOSE=false
VAGRANT_BOXES=
ANSIBLE_ROLES=
CONFIG_FILE=
while [[ $# -ge 1 ]]
do
    case "$1" in
        --ansible-role)
            if [ -z "$2" ]
            then
                error "Argument is required for the $1 option"
                usage
                exit 1
            fi
            ANSIBLE_ROLES="${ANSIBLE_ROLES} $2"
            shift
            ;;
        --config-file)
            CONFIG_FILE="$(resolve_config_file "$2" "${CONFIG_FILE}" "${REPOSITORY_DIRECTORY}")"
            [ $? -ne 0 ] && { printf "$CONFIG_FILE"; exit 1; }
            shift
            ;;
        -h|--help)
            usage
            exit 0
        ;;
        -v|--verbose)
            IS_VERBOSE=true
        ;;
        --vagrant-box)
            if [ -z "$2" ]
            then
                error "Argument is required for the $1 option"
                usage
                exit 1
            fi
            VAGRANT_BOXES="${VAGRANT_BOXES} $2"
            shift
        ;;
        *)
            # Unknown option
            usage
            exit 1
        ;;
    esac
    shift
done

if [ -z "${CONFIG_FILE}" ]
then
    CONFIG_FILE="${DEFAULT_CONFIG_FILE}"
fi

if [ -n "${ANSIBLE_ROLES}" ] && [ -n "${VAGRANT_BOXES}" ]
then
    for ANSIBLE_ROLE in ${ANSIBLE_ROLES}
    do
        for VAGRANT_BOX in ${VAGRANT_BOXES}
        do
            run "${ANSIBLE_ROLE}" "${VAGRANT_BOX}" "${REPOSITORY_DIRECTORY}" ${IS_VERBOSE}
        done
    done
    exit 0;
fi

tail -n+3 "${CONFIG_FILE}" | while IFS='' read -r line || [[ -n "$line" ]]
do
    FOUND=true
    # Remove trailing pipe (because we can use them or not)
    line=$(echo "${line}" | sed 's/^\s*|//' | sed 's/|\s*$//')
    CURRENT_ANSIBLE_ROLE=$(echo "${line}" | cut -d '|' -f 1 | sed 's/^\s*//' | sed 's/\s*$//')
    CURRENT_VAGRANT_BOX=$(echo "${line}" | cut -d '|' -f 2 | sed 's/^\s*//' | sed 's/\s*$//')

    if [ -n "${ANSIBLE_ROLES}" ]
    then
        FOUND=false
        for ANSIBLE_ROLE in ${ANSIBLE_ROLES}
        do
            if [ "${CURRENT_ANSIBLE_ROLE}" == "${ANSIBLE_ROLE}" ]
            then
                FOUND=true
                break
            fi
        done
    fi

    if [ -n "${VAGRANT_BOXES}" ]
    then
        FOUND=false
        for VAGRANT_BOX in ${VAGRANT_BOXES}
        do
            if [ "${CURRENT_VAGRANT_BOX}" == "${VAGRANT_BOX}" ]
            then
                FOUND=true
                break
            fi
        done
    fi

    ${FOUND} || continue

    run "${CURRENT_ANSIBLE_ROLE}" "${CURRENT_VAGRANT_BOX}" "${REPOSITORY_DIRECTORY}" ${IS_VERBOSE}
done
