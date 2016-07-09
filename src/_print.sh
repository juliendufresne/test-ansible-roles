#!/usr/bin/env bash

error() {
    local message="$1"

    printf "\e[1;91m%s\e[0m\n\n" "${message}"
}

warning() {
    local message="$1"

    printf "\e[1;93m%s\e[0m\n\n" "${message}"
}
