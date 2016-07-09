#!/usr/bin/env bash

REPOSITORY_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${REPOSITORY_DIRECTORY}/src/_print.sh"
. "${REPOSITORY_DIRECTORY}/src/_result.sh"
. "${REPOSITORY_DIRECTORY}/src/_run.sh"
. "${REPOSITORY_DIRECTORY}/src/_usage.sh"

DEFAULT_ANSIBLE_ROLE="juliendufresne.influxdb"
DEFAULT_VAGRANT_BOX="geerlingguy/ubuntu1604"
IS_VERBOSE=false
VAGRANT_BOXES=
ANSIBLE_ROLES=
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

if [ -z "${ANSIBLE_ROLES}" ]
then
    ANSIBLE_ROLES="${DEFAULT_ANSIBLE_ROLE}"
fi

if [ -z "${VAGRANT_BOXES}" ]
then
    VAGRANT_BOXES="${DEFAULT_VAGRANT_BOX}"
fi

for ANSIBLE_ROLE in ${ANSIBLE_ROLES}
do
    for VAGRANT_BOX in ${VAGRANT_BOXES}
    do
        run "${ANSIBLE_ROLE}" "${VAGRANT_BOX}" "${REPOSITORY_DIRECTORY}" ${IS_VERBOSE}
    done
done
