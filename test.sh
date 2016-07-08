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

printf "* booting machine: "
vagrant up --no-provision &>/dev/null
handle_result $?

OUTPUT_FILE=$(mktemp)
printf "* Fresh provisioning test: "
vagrant provision &>"${OUTPUT_FILE}"
grep -q 'unreachable=0.*failed=0' "${OUTPUT_FILE}"
handle_result $?
rm "${OUTPUT_FILE}"

vagrant destroy -f >/dev/null
