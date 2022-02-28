#!/bin/bash
#
# Name: keepassxc-sync
# Date: 12/04/2020
# Author: Sebastien Malissard
# Brief: Synchronize the local keepassxc database with a remote database over ssh
#

KEEPASSXC_SYNC_DIR="/opt/keepassxc-sync/scripts/"

# shellcheck source=./common.bash
source "${KEEPASSXC_SYNC_DIR}/common.bash"

# User configuration variables
cache_hash_file="/home/${USER}/.cache/keepassxc-sync/hash_Passwords_kdbx"
local_db_file="<path_to>/Passwords.kdbx"
remote_db_file="<path_to>/Passwords.kdbx"
remote_server="0.0.0.0"
remote_ssh_port=22
remote_ssh_user=user

# Internal variables
keepass_cmd=${0}
tmp_remote_db_file=""
force_update_remote=0

error_exit()
{
    # All error in this script are fatal, otherwise used warning function
    quit 1
}

quit()
{
    if [ -f "${tmp_remote_db_file}" ]; then
        rm "${tmp_remote_db_file}"
    fi
    
    exit "$@"
}

update_cache()
{
    if [ ! -f "${cache_hash_file}" ]; then
        if ! mkdir -p "$(dirname "${cache_hash_file}")"; then
            warning "Fail to create directory: '$(dirname "${cache_hash_file}")'."
        fi
    fi
    
    # Create (or update) cache file
    if ! echo "${1}" > "${cache_hash_file}"; then
        warning "Fail to create (or update) cache hash file: '${cache_hash_file}'."
    fi
}

main()
{
    # Check if local database exist
    if [ ! -f "${local_db_file}" ]; then
        error "Local database file doesn't exist: '${local_db_file}'."
    fi
    
    # Create the temporary file remote database
    if ! tmp_remote_db_file="$(mktemp -t keepass-sync.XXXXXXXXXX)"; then
        error "Fail to create a temporary file."
    fi
    
    # Download the remote database
    if ! scp -o ConnectTimeout=10 -P ${remote_ssh_port} ${remote_ssh_user}@${remote_server}:${remote_db_file} "${tmp_remote_db_file}"; then
        debug "Command failed: 'scp -P ${remote_ssh_port} ${remote_ssh_user}@${remote_server}:${remote_db_file} \"${tmp_remote_db_file}\"'"
        error "Fail to download remote database."
    fi
    
    # Compute hash of databases
    hash_local=$(sha256sum "${local_db_file}" | awk '{print $1}')
    hash_remote=$(sha256sum "${tmp_remote_db_file}" | awk '{print $1}')
    
    if [ ${force_update_remote} -eq 1 ]; then
        # Force update remote: sync cache hash with remote hash
        hash_cache="${hash_remote}"
    else
        # Get hash cache from local file
        if ! hash_cache=$(cat "${cache_hash_file}"); then
            warning "Fail to get cache hash."
            hash_cache=""
        fi
    fi
    
    debug "Remote database hash : ${hash_remote}"
    debug "Local database hash  : ${hash_local}"
    debug "Cache hash           : ${hash_cache}"
    
    # Compare all hash
    if [ "${hash_remote}" = "${hash_local}" ]; then
    
        # Update cache if needed
        if [ "${hash_local}" != "${hash_cache}" ]; then
            update_cache "${hash_local}"
        fi
        
        info "Databases are in sync."
        
    elif [ "${hash_cache}" = "${hash_local}" ]; then
            
        # Update the local database
        if ! mv "${tmp_remote_db_file}" "${local_db_file}"; then
            error "Fail to update local database."
        fi
        
        update_cache "${hash_remote}"
        
        info "Sucess to update local database."
            
    elif [ "${hash_cache}" = "${hash_remote}" ]; then
            
        # Update the remote database
        if ! scp -P ${remote_ssh_port} "${local_db_file}" ${remote_ssh_user}@${remote_server}:${remote_db_file}; then
            debug "Command failed: 'scp -P ${remote_ssh_port} \"${local_db_file}\" ${remote_ssh_user}@${remote_server}:${remote_db_file}'"
            error "Fail to update remote database."
        fi
        
        update_cache "${hash_local}"
        
        info "Sucess to update remote database."
    
    else # All hash are different
        
        # Rename temporary local database with extention .kbdx to be detect bu KeePassXC
        if ! mv "${tmp_remote_db_file}" "${tmp_remote_db_file}.kdbx"; then
            error "Fail to rename '${tmp_remote_db_file}' to '${tmp_remote_db_file}.kdbx'."
        fi
        
        info "Need to manually merge the database!"
        info "First go to KeePassXC menu: 'Database' > 'Merge from KeePassXC database' and then import '${tmp_remote_db_file}.kdbx'."
        info "Next run the following command:"
        info "    rm \"${tmp_remote_db_file}.kdbx\""
        info "    ${keepass_cmd} --force-update-remote"
    fi
    
    quit 0
}

# Parse command arguments
while (( "$#" )); do
    case "$1" in
        -f|--force-update-remote)
            force_update_remote=1
            shift
            ;;
        *)
            error "Invalid argument."
            ;;
    esac
done

main
