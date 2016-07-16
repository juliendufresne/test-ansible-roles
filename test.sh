#!/usr/bin/env bash

REPOSITORY_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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
ENABLE_VBGUEST="false"
PRE_SCRIPT=
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
            resolve_config_file "$2"
            shift
        ;;
        --enable-vbguest)
            ENABLE_VBGUEST="true"
        ;;
        -h|--help)
            usage
            exit 0
        ;;
        --pre-script)
            resolve_pre_script "$2"
            shift
        ;;
        -v|--verbose)
            IS_VERBOSE=true
        ;;
        --vagrant-box)
            resolve_vagrant_box "$2"
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

[ -z "${CONFIG_FILE}" ] && CONFIG_FILE="${DEFAULT_CONFIG_FILE}"

if [ -n "${ANSIBLE_ROLES}" ] && [ -n "${VAGRANT_BOXES}" ]
then
    for ANSIBLE_ROLE in ${ANSIBLE_ROLES}
    do
        for VAGRANT_BOX in ${VAGRANT_BOXES}
        do
            run "${ANSIBLE_ROLE}" "${VAGRANT_BOX}" "${REPOSITORY_DIRECTORY}" "${PRE_SCRIPT}" ${IS_VERBOSE} ${ENABLE_VBGUEST} \
                || display_command "$0" "${ANSIBLE_ROLE}" "${VAGRANT_BOX}" "${PRE_SCRIPT}" ${ENABLE_VBGUEST}
            echo
        done
    done
    exit 0
fi

tail -n+3 "${CONFIG_FILE}" | while IFS='' read -r line || [[ -n "$line" ]]
do
    FOUND=true
    # Remove trailing pipe (because we can use them or not)
    line=$(echo "${line}" | sed 's/^\s*|//' | sed 's/|\s*$//')
    CURRENT_ANSIBLE_ROLE="$(echo "${line}" | cut -d '|' -f 1 | sed 's/^\s*//' | sed 's/\s*$//')"
    CURRENT_VAGRANT_BOX="$(echo "${line}" | cut -d '|' -f 2 | sed 's/^\s*//' | sed 's/\s*$//')"
    PRE_SCRIPT="$(echo "${line}" | cut -d '|' -f 4 | sed 's/^\s*//' | sed 's/\s*$//')"

    [ "yes" == "$(echo "${line}" | cut -d '|' -f 3 | sed 's/^\s*//' | sed 's/\s*$//')" ] && ENABLE_VBGUEST="true" || ENABLE_VBGUEST="false"

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

    run "${CURRENT_ANSIBLE_ROLE}" "${CURRENT_VAGRANT_BOX}" "${REPOSITORY_DIRECTORY}" "${PRE_SCRIPT}" ${IS_VERBOSE} ${ENABLE_VBGUEST} \
        || display_command "$0" "${CURRENT_ANSIBLE_ROLE}" "${CURRENT_VAGRANT_BOX}" "${PRE_SCRIPT}" ${ENABLE_VBGUEST}
    echo
done
