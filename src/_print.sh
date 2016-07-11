#!/usr/bin/env bash

display_command() {
    local script_name="$1"
    local ansible_role="$2"
    local vagrant_box="$3"
    local pre_script="$4"
    local enable_vbguest=$5

    warning "This test has failed. You can rerun it with the following command"

    >&2 printf '%s --verbose --ansible-role "%s" --vagrant-box "%s"' "${script_name}" "${ansible_role}" "${vagrant_box}"
    [ -n "${pre_script}" ] && >&2 printf ' --pre-script "%s"' "${pre_script}"
    ${enable_vbguest} && >&2 printf ' --enable-vbguest'
    >&2 printf "\n"
}

error() {
    local message="$1"

    >&2 printf "\e[1;91m%s\e[0m\n" "${message}"
}

warning() {
    local message="$1"

    >&2 printf "\e[1;93m%s\e[0m\n" "${message}"
}
