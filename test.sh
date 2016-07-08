#!/usr/bin/env bash

handle_result() {
    local args=$1
    local output_file=$2
    local verbose=$3

    if [ ${args} -ne 0 ]
    then
        printf "\e[1;31m%s\e[0m\n" "fail"
        ${verbose} && cat ${output_file}

        return 1;
    fi
    printf "\e[1;32m%s\e[0m\n" "pass"

    return 0;
}

usage() {
    printf "\
\e[1mNAME\e[0m
       $0 - Test ansible roles

\e[1mSYNOPSIS\e[0m
       $0 [OPTION...]

\e[1mDESCRIPTION\e[0m
       Test ansible role in a vagrant box

        -h, --help          show this help
        -v, --verbose       Increase verbosity
"
}

VERBOSE=false
while [[ $# -ge 1 ]]
do
    case "$1" in
        -h|--help)
            usage
            exit 0
        ;;
        -v|--verbose)
            VERBOSE=true
        ;;
        *)
            # Unknown option
            usage
            exit 1
        ;;
    esac
    shift
done

PREVIOUS_VAGRANT_BOX_ID=$(vagrant global-status 2>/dev/null | grep " ansible_role_ubuntu_1604 " | awk '{ print $1; }')
if [ ! -z "${PREVIOUS_VAGRANT_BOX_ID}" ]
then
    vagrant destroy -f ${PREVIOUS_VAGRANT_BOX_ID}
fi

REPOSITORY_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TESTING_DIRECTORY="$(mktemp -d)"

# Ensure we are in the repository root
cd "${REPOSITORY_DIRECTORY}"
cp -r inventory playbooks requirements.yml Vagrantfile "${TESTING_DIRECTORY}"

cd "${TESTING_DIRECTORY}"
OUTPUT_FILE=$(mktemp)
printf "* booting machine: "
vagrant up --no-provision &>"${OUTPUT_FILE}"
handle_result $? "${OUTPUT_FILE}" ${VERBOSE}

OUTPUT_FILE=$(mktemp)
printf "* Fresh provisioning test: "
vagrant provision &>"${OUTPUT_FILE}"
grep -q 'unreachable=0.*failed=0' "${OUTPUT_FILE}"
handle_result $? "${OUTPUT_FILE}" ${VERBOSE}
rm "${OUTPUT_FILE}"

OUTPUT_FILE=$(mktemp)
printf "* Idempotent test: "
vagrant provision &>"${OUTPUT_FILE}"
grep -q 'changed=0.*unreachable=0.*failed=0' "${OUTPUT_FILE}"
handle_result $? "${OUTPUT_FILE}" ${VERBOSE}
rm "${OUTPUT_FILE}"

vagrant destroy -f >/dev/null
cd "${REPOSITORY_DIRECTORY}"
rm -rf "${TESTING_DIRECTORY}"
