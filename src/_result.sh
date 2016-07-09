#!/usr/bin/env bash

handle_result() {
    local args=$1
    local output_file=$2
    local is_verbose=$3

    if [ ${args} -ne 0 ]
    then
        printf "\e[1;31m%s\e[0m\n" "fail"
        ${is_verbose} && cat ${output_file}

        return 1;
    fi
    printf "\e[1;32m%s\e[0m\n" "pass"

    return 0;
}
