function missing_var_exit {
    error_exit "Missing environment variable '${1}'" 2
}

function error_exit {
    echo "${1}" >&2   ## Send message to stderr. Exclude >&2 if you don't want it that way.
    exit "${2:-1}"  ## Return a code specified by $2 or 2 by default.
}
