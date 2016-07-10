#!/usr/bin/env bash

handle_result() {
    local return_code=$1
    local output_file=$2
    local is_verbose=$3
    local report=$4

    if [ ${return_code} -ne 0 ]
    then
        printf "\e[1;31m%s\e[0m\n" "fail"
        ${is_verbose} && cat ${output_file}
        ${report} && report_failure

        return 1;
    fi
    printf "\e[1;32m%s\e[0m\n" "pass"
    ${report} && report_success

    return 0;
}
