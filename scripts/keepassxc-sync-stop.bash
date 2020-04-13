#!/bin/bash

KEEPASSXC_SYNC_DIR="/opt/keepassxc-sync/scripts/"

# shellcheck source=./common.bash
source "${KEEPASSXC_SYNC_DIR}/common.bash"

error_exit()
{
    ${SHELL}
    
    exit 1
}

main()
{
    # Save the current PID for the main process
    echo $$ > "${keepassxc_term_pid_file}"

    info "Run keepassxc-sync-cli..."
    if ! $(keepassxc-sync-cli); then
        error_exit
    fi
    
    # To see the last messages before close the console
    sleep 0.5
}

main
