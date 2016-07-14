#!/usr/bin/env bash

boot_vagrant_box() {
    local is_verbose=$1
    local output_file=$(readlink -m "boot_vagrant_box__vagrant_up.out")

    printf "* booting vagrant box: "
    vagrant up --no-provision &>"${output_file}"

    handle_result $? "${output_file}" ${is_verbose} false

    return $?
}

clean_previous_vagrant_box() {
    local previous_vagrant_box_id=$(vagrant global-status 2>/dev/null | grep " ansible_role_ubuntu_1604 " | awk '{ print $1; }')

    if [ ! -z "${previous_vagrant_box_id}" ]
    then
        vagrant destroy -f ${previous_vagrant_box_id} &>/dev/null
    fi
}

create_vagrantfile() {
    local vagrant_box="$1"
    local is_vbguest_enabled="$2"
    local pre_script="$3"
    local line=

    [ -z "${pre_script}" ] && pre_script="provision/empty.sh"

    while read -r line
    do
        while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]]
        do
            LHS=${BASH_REMATCH[1]}
            RHS="$(eval echo "\"${LHS}\"")"
            line=${line//${LHS}/${RHS}}
        done
        echo "$line" >> Vagrantfile
    done < Vagrantfile.template
}

test_clean_install() {
    local is_verbose=$1
    local output_file=$(readlink -m "test_clean_install__vagrant_provision.out")

    printf "* Testing clean install: "
    vagrant provision &>"${output_file}"
    grep -q 'unreachable=0.*failed=0' "${output_file}"

    handle_result $? "${output_file}" ${is_verbose} true

    return $?
}

test_idempotent() {
    local is_verbose=$1
    local output_file=$(readlink -m "test_idempotent__vagrant_provision.out")

    printf "* Idempotent test: "
    vagrant provision &>"${output_file}"
    grep -q 'changed=0.*unreachable=0.*failed=0' "${output_file}"

    handle_result $? "${output_file}" ${is_verbose} true

    return $?
}

run() {
    local ansible_role="$1"
    local vagrant_box="$2"
    local repository_directory="$3"
    local pre_script="$4"
    local is_verbose=$5
    local is_vbguest_enabled="$6"
    local testing_directory="$(mktemp -d)"
    local status=0

    printf "# Testing ansible role \033[1;34m%s\033[0m in vagrant box \033[1;34m%s\033[0m\n" "${ansible_role}" "${vagrant_box}"

    clean_previous_vagrant_box

    # Ensure we are in the repository root
    cd "${repository_directory}"
    cp -r inventory playbooks provision requirements.yml Vagrantfile.template "${testing_directory}"

    # Checks ansible roles requirements
    if [ ! -f "playbooks/${ansible_role}.yml" ]
    then
        error "You need to create the file playbooks/${ansible_role}.yml"
        return 1
    fi

    if echo "${ansible_role}" | grep -q "\." && ! grep -q "${ansible_role}" requirements.yml
    then
        warning "Your playbook ${ansible_role} looks like an ansible galaxy role but is not defined in requirements.yml"
    fi

    cd "${testing_directory}"

    create_vagrantfile "${vagrant_box}" "${is_vbguest_enabled}" "${pre_script}"
    local report_file=$(ensure_report_file_exists "${repository_directory}" "${ansible_role}")

    boot_vagrant_box ${is_verbose} || status=1
    start_new_report
    test_clean_install ${is_verbose} || status=1
    test_idempotent ${is_verbose} || status=1

    save_report "${report_file}"

    vagrant destroy -f >/dev/null
    cd
    rm -rf "${testing_directory}"

    return ${status}
}
