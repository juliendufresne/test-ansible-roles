#!/usr/bin/env bash

boot_vagrant_box() {
    local is_verbose=$1
    local output_file=$(mktemp)

    printf "* booting vagrant box: "
    vagrant up --no-provision &>"${output_file}"
    handle_result $? "${output_file}" ${is_verbose}
}

clean_after_tests() {
    local testing_directory="$1"

    vagrant destroy -f >/dev/null
    cd
    rm -rf "${testing_directory}"
}

clean_previous_vagrant_box() {
    local previous_vagrant_box_id=$(vagrant global-status 2>/dev/null | grep " ansible_role_ubuntu_1604 " | awk '{ print $1; }')

    if [ ! -z "${previous_vagrant_box_id}" ]
    then
        vagrant destroy -f ${previous_vagrant_box_id}
    fi
}

create_vagrantfile() {
    while read -r line ; do
        while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
            LHS=${BASH_REMATCH[1]}
            RHS="$(eval echo "\"${LHS}\"")"
            line=${line//${LHS}/${RHS}}
        done
        echo "$line" >> Vagrantfile
    done < Vagrantfile.template
}

test_clean_install() {
    local is_verbose=$1
    local output_file=$(mktemp)

    printf "* Testing clean install: "
    vagrant provision &>"${output_file}"
    grep -q 'unreachable=0.*failed=0' "${output_file}"
    handle_result $? "${output_file}" ${is_verbose}

    rm "${output_file}"
}

test_idempotent() {
    local is_verbose=$1
    local output_file=$(mktemp)

    printf "* Idempotent test: "
    vagrant provision &>"${output_file}"
    grep -q 'changed=0.*unreachable=0.*failed=0' "${output_file}"
    handle_result $? "${output_file}" ${is_verbose}

    rm "${output_file}"
}

run() {
    local ansible_role="$1"
    local vagrant_box="$2"
    local repository_directory="$3"
    local is_verbose=$4
    local testing_directory="$(mktemp -d)"

    printf "# Testing ansible role \033[1;34m%s\033[0m in vagrant box \033[1;34m%s\033[0m\n" "${ansible_role}" "${vagrant_box}"

    clean_previous_vagrant_box

    # Ensure we are in the repository root
    cd "${repository_directory}"
    cp -r inventory playbooks requirements.yml Vagrantfile.template "${testing_directory}"

    # Checks ansible roles requirements
    if [ ! -f "playbooks/${ansible_role}.yml" ]
    then
        error "You need to create the file playbooks/${ansible_role}.yml"
        return 1
    fi

    if echo "${ansible_role}" | grep -q "." && ! grep -q "${ansible_role}" requirements.yml
    then
        warning "Your playbook ${ansible_role} looks like an ansible galaxy role but is not defined in requirements.yml"
    fi

    cd "${testing_directory}"

    create_vagrantfile

    boot_vagrant_box ${is_verbose}
    test_clean_install ${is_verbose}
    test_idempotent ${is_verbose}

    clean_after_tests "${testing_directory}"

    return 0
}
