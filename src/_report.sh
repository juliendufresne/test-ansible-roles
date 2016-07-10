#!/usr/bin/env bash

# file containing the current report line
REPORT_CURRENT_FILE=

ensure_report_file_exists() {
    local repository_directory="$1"
    local ansible_role="$2"
    local report_file="${repository_directory}/reports/${ansible_role}.md"
    local template_file="${repository_directory}/reports/template"
    local template_line=
    local LHS=
    local RHS=

    if [ ! -f "${report_file}" ]
    then
        while read -r template_line
        do
            while [[ "$template_line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]]
            do
                LHS=${BASH_REMATCH[1]}
                RHS="$(eval echo "\"${LHS}\"")"
                template_line=${template_line//${LHS}/${RHS}}
            done
            echo "$template_line" >> "${report_file}"
        done < "${template_file}"
    fi

    echo "${report_file}"
}

report_display_column() {
    [ -z "${REPORT_CURRENT_FILE}" ] && return

    local pad="$1"
    local value="$2"

    pad=$(echo "$pad"|tr '[:alnum:]' ' '|sed 's/| //'|sed 's/ |//')
    printf '| %s%0.*s ' "${value}" $((${#pad} - ${#value})) "${pad}"
}

report_failure() {
    [ -z "${REPORT_CURRENT_FILE}" ] && return

    printf "| %s " "![FAIL](https://img.shields.io/badge/status-fail-red.svg)" >> ${REPORT_CURRENT_FILE}
}

report_success() {
    [ -z "${REPORT_CURRENT_FILE}" ] && return

    printf "| %s " "![OK](https://img.shields.io/badge/status-pass-brightgreen.svg)" >> ${REPORT_CURRENT_FILE}
}

save_report() {
    [ -z "${REPORT_CURRENT_FILE}" ] && return

    local report_file="$1"
    local distribution=$(cat "${REPORT_CURRENT_FILE}"|cut -d '|' -f 2 |sed 's/^\s*//'|sed 's/\s*$//')
    local new_line=

    echo " |" >> "${REPORT_CURRENT_FILE}"

    if grep -q -m 1 "| ${distribution}" "${report_file}"
    then
        line_number=$(grep -n -m 1 "| ${distribution}" "${report_file}" | sed 's/^\([0-9]*\).*$/\1/')
        new_line=$(cat "${REPORT_CURRENT_FILE}"|sed -e 's/[\/&]/\\&/g')
        sed -i "${line_number}s/.*/${new_line}/" "${report_file}"
    else
        cat "${REPORT_CURRENT_FILE}" >> "${report_file}"
    fi

    REPORT_CURRENT_FILE=
}

start_new_report() {
    REPORT_CURRENT_FILE=$(readlink -m "report_line.md")
    install_lsb_release_package || {
        REPORT_CURRENT_FILE=
        warning "Unable to install lsb_release binary on the guest. No reports will be generated"
        return 0
    }
    local id="$(vagrant ssh -- -n 'lsb_release --short --id')"
    local release="$(vagrant ssh -- -n 'lsb_release --short --release')"
    local distribution="$id $release"
    local codename="$(vagrant ssh -- -n 'lsb_release --short --codename')"

    if [ -n "${codename}" ]
    then
        distribution="$distribution ($codename)"
    fi

    report_display_column "| Distribution           |" "$distribution"    >> "${REPORT_CURRENT_FILE}"
    report_display_column "| last check date     |"   "$(date +"%F %T")" >> "${REPORT_CURRENT_FILE}"
}
