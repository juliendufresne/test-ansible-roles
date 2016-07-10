#!/usr/bin/env bash

find_package_manager() {
    local package_manager=
    for package_manager in 'apt-get' 'yum'
    do
        if vagrant ssh -- -n "which ${package_manager}" &>/dev/null
        then
            echo "${package_manager}"
            return 0
        fi
    done

    return 1
}

install_lsb_release_package() {
    local package_manager=$(find_package_manager)
    local known_package_names='lsb_release redhat-lsb'

    # is it already installed ?
    for package_name in ${known_package_names}
    do
        vagrant ssh -- -n "which lsb_release" &>/dev/null && return 0
    done

    if [ -z "${package_manager}" ]
    then
        return 1
    fi

    for package_name in ${known_package_names}
    do
        case "${package_manager}" in
                "apt-get")
                        vagrant ssh -- -n "sudo apt-get install -y ${package_name}" &>/dev/null && return 0
                ;;
                "yum")
                        vagrant ssh -- -n "sudo yum install -y ${package_name}" &>/dev/null && return 0
                ;;
        esac
    done

    return 1
}
