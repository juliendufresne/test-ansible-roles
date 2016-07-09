#!/usr/bin/env bash

REPORT_CURRENT_FILE=

ensure_report_file_exists() {
    local repository_directory="$1"
    local ansible_role="$2"
    local file="${repository_directory}/reports/${ansible_role}.md"
    local template="${repository_directory}/reports/template"

    if [ ! -f "${file}" ]
    then
        while read -r line
        do
            while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]]
            do
                LHS=${BASH_REMATCH[1]}
                RHS="$(eval echo "\"${LHS}\"")"
                line=${line//${LHS}/${RHS}}
            done
            echo "$line" >> "${file}"
        done < "${template}"
    fi

    echo "${file}"
}

report_failure() {
    printf "| %s " "![FAIL](https://img.shields.io/badge/status-fail-red.svg)" >> ${REPORT_CURRENT_FILE}
}

report_success() {
    printf "| %s " "![OK](https://img.shields.io/badge/status-pass-brightgreen.svg)" >> ${REPORT_CURRENT_FILE}
}

save_report() {
    local report_file="$1"
    local vagrant_box="$2"

    echo " |" >>"${REPORT_CURRENT_FILE}"

    if grep -q "| ${vagrant_box}" "${report_file}"
    then
        RSLT=$(cat "${REPORT_CURRENT_FILE}"|sed -e 's/[\/&]/\\&/g')
        PATTERN=$(grep "| ${vagrant_box}" "${report_file}" | sed 's/[^^]/[&]/g; s/\^/\\^/g')
        sed -i "s/${PATTERN}/${RSLT}/" "${report_file}"
    else
        cat "${REPORT_CURRENT_FILE}" >> "${report_file}"
    fi

    rm ${REPORT_CURRENT_FILE}
    REPORT_CURRENT_FILE=
}

report_display_column() {
    local pad="$1"
    local value="$2"

    pad=$(echo "$pad"|tr '[:alnum:]' ' '|sed 's/| //'|sed 's/ |//')
    printf '| %s%0.*s ' "${value}" $((${#pad} - ${#value})) "${pad}"
}

start_new_report() {
    REPORT_CURRENT_FILE=$(mktemp)
    report_display_column "| vagrant box             |" "$1"               >> "${REPORT_CURRENT_FILE}"
    report_display_column "| last check date     |"     "$(date +"%F %T")" >> "${REPORT_CURRENT_FILE}"
}
