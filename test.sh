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

error() {
    local message="$1"

    printf "\e[1;91m%s\e[0m\n\n" "${message}"
}

run() {
    local repository_directory="$1"
    local is_verbose=$2
    local testing_directory="$(mktemp -d)"
    local previous_vagrant_box_id=$(vagrant global-status 2>/dev/null | grep " ansible_role_ubuntu_1604 " | awk '{ print $1; }')

    if [ ! -z "${previous_vagrant_box_id}" ]
    then
        vagrant destroy -f ${previous_vagrant_box_id}
    fi

    # Ensure we are in the repository root
    cd "${repository_directory}"
    cp -r inventory playbooks requirements.yml Vagrantfile.template "${testing_directory}"

    cd "${testing_directory}"

    # Replace variables in Vagrantfile.template
    while read -r line ; do
        while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
            LHS=${BASH_REMATCH[1]}
            RHS="$(eval echo "\"${LHS}\"")"
            line=${line//${LHS}/${RHS}}
        done
        echo "$line" >> Vagrantfile
    done < Vagrantfile.template

    local output_file=$(mktemp)
    printf "* booting machine: "
    vagrant up --no-provision &>"${output_file}"
    handle_result $? "${output_file}" ${is_verbose}

    local output_file=$(mktemp)
    printf "* Fresh provisioning test: "
    vagrant provision &>"${output_file}"
    grep -q 'unreachable=0.*failed=0' "${output_file}"
    handle_result $? "${output_file}" ${is_verbose}
    rm "${output_file}"

    local output_file=$(mktemp)
    printf "* Idempotent test: "
    vagrant provision &>"${output_file}"
    grep -q 'changed=0.*unreachable=0.*failed=0' "${output_file}"
    handle_result $? "${output_file}" ${is_verbose}
    rm "${output_file}"

    vagrant destroy -f >/dev/null
    cd "${repository_directory}"
    rm -rf "${testing_directory}"
}

usage() {
    printf "\
\e[1mNAME\e[0m
       $0 - Test ansible roles

\e[1mSYNOPSIS\e[0m
       $0 [OPTION...]

\e[1mDESCRIPTION\e[0m
       Test ansible role in a vagrant box

        -h, --help                  show this help
        -v, --verbose               increase verbosity
        --vagrant-box VAGRANT_BOX   use specified vagrant box instead of default one
"
}

IS_VERBOSE=false
VAGRANT_BOXES=
while [[ $# -ge 1 ]]
do
    case "$1" in
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
                error "Argument is required for the --vagrant-box option"
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

if [ -z "${VAGRANT_BOXES}" ]
then
    VAGRANT_BOXES="geerlingguy/ubuntu1604"
fi

REPOSITORY_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for VAGRANT_BOX in ${VAGRANT_BOXES}
do
    run "${REPOSITORY_DIRECTORY}" ${IS_VERBOSE}
done
