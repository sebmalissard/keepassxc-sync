#!/bin/bash

KEEPASSXC_SYNC_DIR="/opt/keepassxc-sync/scripts/"

# shellcheck source=./common.bash
source "${KEEPASSXC_SYNC_DIR}/common.bash"

# Internal variables
keepassxc_wait_pid_timeout=3

error_exit()
{
    if [ -f "${keepassxc_term_pid_file}" ]; then
        rm "${keepassxc_term_pid_file}"
    fi
    
    exit 1
}

main()
{
    debug "Start of KeePassXC sync"
    
    if x-terminal-emulator -e "${KEEPASSXC_SYNC_DIR}/keepassxc-sync-start.bash"; then

        info "Waiting to get keepassxc-sync terminal PID..."
        while ((keepassxc_wait_pid_timeout > 0)) && [ ! -f "${keepassxc_term_pid_file}" ]; do
           sleep 1
           ((keepassxc_start_timeout -= 1))
           echo -n "."
        done
        echo ""
        
        if ! pid=$(cat "${keepassxc_term_pid_file}"); then
            error "Fail to get keepassxc-sync terminal PID"
        fi
        
        info "Waiting end of the keepassxc-sync terminal..."
        while [ -e "/proc/${pid}" ]; do
            sleep 0.5;
        done
        
        if ! pid=$(pidof keepassxc); then
            error "Fail to get KeePassXC PID"
        fi
        
        info "Waiting end of the KeePassXC application..."
        while [ -e "/proc/${pid}" ]; do
            sleep 0.5;
        done

        if x-terminal-emulator -e "${KEEPASSXC_SYNC_DIR}/keepassxc-sync-stop.bash"; then

            info "Waiting to get keepassxc-sync terminal PID..."
            while ((keepassxc_wait_pid_timeout > 0)) && [ ! -f "${keepassxc_term_pid_file}" ]; do
               sleep 1
               ((keepassxc_start_timeout -= 1))
               echo -n "."
            done
            echo ""
            
            if ! pid=$(cat "${keepassxc_term_pid_file}"); then
                error "Fail to get keepassxc-sync terminal PID"
            fi
            
            info "Waiting end of the keepassxc-sync terminal..."
            while [ -e "/proc/${pid}" ]; do
                sleep 0.5;
            done
        fi
    fi
    
    debug "End of KeePassXC sync"
}

main
