#!/usr/bin/env bash

handle_result() {
    local args=$1

    if [ ${args} -ne 0 ]
    then
        printf "\e[1;31m%s\e[0m\n" "fail"

        return 1;
    fi
    printf "\e[1;32m%s\e[0m\n" "pass"

    return 0;
}

REPOSITORY_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TESTING_DIRECTORY="$(mktemp -d)"

# Ensure we are in the repository root
cd "${REPOSITORY_DIRECTORY}"
cp -r inventory playbooks requirements.yml Vagrantfile "${TESTING_DIRECTORY}"

cd "${TESTING_DIRECTORY}"
printf "* booting machine: "
vagrant up --no-provision &>/dev/null
handle_result $?

OUTPUT_FILE=$(mktemp)
printf "* Fresh provisioning test: "
vagrant provision &>"${OUTPUT_FILE}"
grep -q 'unreachable=0.*failed=0' "${OUTPUT_FILE}"
handle_result $?
rm "${OUTPUT_FILE}"

OUTPUT_FILE=$(mktemp)
printf "* Idempotent test: "
vagrant provision &>"${OUTPUT_FILE}"
grep -q 'changed=0.*unreachable=0.*failed=0' "${OUTPUT_FILE}"
handle_result $?
rm "${OUTPUT_FILE}"

vagrant destroy -f >/dev/null
cd "${REPOSITORY_DIRECTORY}"
rm -rf "${TESTING_DIRECTORY}"
