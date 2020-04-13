#!/bin/bash

cur_dir=$(dirname "$(readlink -f "${0}")")

if [ ! -f "/bin/bash" ]; then
    echo "ERROR: '/bin/bash' doesn't exist."
    echo "ERROR Can't install keepassxc-sync. Bash shell is required."
    exit 1
fi

opt_install_path="/opt/keepassxc-sync"
bin_install_path="/usr/local/bin"

# shellcheck source=./scripts/common.bash
source "${cur_dir}/scripts/common.bash"

error_exit()
{
    exit 1
}

main()
{
    if ! hash keepassxc; then
        error "KeePassXC is not installed. Why did you try to install keepassxc-sync (keepasssxc-sync is only an overlay to KeePassXC)?"
    fi

    if [ -d "${opt_install_path}" ]; then
        info "Previous keepassxc-sync installation detected."
        
        read -p "Do you want erase the current keepassxc-sync installation (y/N)?  " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
        
        if ! sudo rm -rf "${opt_install_path}"; then
            error "Fail to remove old installation directory '/opt/keepassxc-sync'."
        fi
    fi

    if ! sudo mkdir -p "${opt_install_path}"; then
        error "Fail to create directory '/opt/keepassxc-sync'."
    fi

    if ! sudo cp -r "${cur_dir}/scripts" "${opt_install_path}"; then
        error "Fail to install keepassxc-sync in '/opt/keepassxc-sync'."
    fi

    if [ ! -L "${bin_install_path}/keepassxc-sync" ]; then
        rm -f "${bin_install_path}/keepassxc-sync"
        
        if ! sudo ln -s "${opt_install_path}/scripts/keepassxc-sync.bash" "${bin_install_path}/keepassxc-sync"; then
            error "Fail to create symlink in '${bin_install_path}/keepassxc-sync'."
        fi
    fi
    
    if [ ! -L "${bin_install_path}/keepassxc-sync-cli" ]; then
        rm -f "${bin_install_path}/keepassxc-sync-cli"
        
        if ! sudo ln -s "${opt_install_path}/scripts/keepassxc-sync-cli.bash" "${bin_install_path}/keepassxc-sync-cli"; then
            error "Fail to create symlink in '${bin_install_path}/keepassxc-sync-cli'."
        fi
    fi

    if ! xdg-icon-resource install --size 256 "${cur_dir}/share/icons/apps/256x256/keepassxc-sync.png"; then
        warning "Fail to install the keepssxc-sync icon"
    fi

    if ! xdg-desktop-menu install "${cur_dir}/share/applications/keepassxc-sync.desktop"; then
        warning "Fail to install the keepssxc-sync desktop file"
    fi
}

main
