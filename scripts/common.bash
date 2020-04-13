#!/bin/bash

# Set tmp directory variable if empty
TMPDIR="${TMPDIR:-/tmp}"

# Common variable
keepassxc_term_pid_file="${TMPDIR}/keepassxc-sync-terminal-pid"

debug()
{
    echo -e "DEBUG: ${*}" >&2
}

info()
{
    echo -e "\e[1;97mINFO: ${*}\e[0m" >&2
}

warning()
{
    echo -e "\e[1;33mWARNING: ${*}\e[0m" >&2
}

error()
{
    echo -e "\e[1;31mERROR: ${*}\e[0m" >&2
    
    if type error_exit > /dev/null; then
        error_exit
    fi
}
