#!/bin/bash

KEEPASSXC_SYNC_DIR="/opt/keepassxc-sync/scripts/"

# shellcheck source=./common.bash
source "${KEEPASSXC_SYNC_DIR}/common.bash"

# Internal variables
keepassxc_lock_file="${TMPDIR}/keepassxc-${USER}.lock"
keepassxc_start_timeout=10

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
    
    # Start KeePassXC
    keepassxc &
    
    # Wait the pid of keepassxc is not enought, because if we exit quikly (before show the keepassxc
    # gui this script the keepassxc  is also killed.
    
    info "Waiting KeePassXC to start..."
    while ((keepassxc_start_timeout > 0)) && [ ! -f "${keepassxc_lock_file}" ]; do
       sleep 1
       ((keepassxc_start_timeout -= 1))
       echo -n "."
    done 
    echo ""
    
    if [ ${keepassxc_start_timeout} -eq 0 ]; then
        error "Timeout! Fail to start KeePassXC."
    else
        info "Done."
    fi

    # To see the last messages before close the console
    sleep 0.5
}

main
