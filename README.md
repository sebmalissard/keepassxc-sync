# KeePassXC sync

`KeePassXC sync` was developped to synchonize your local KeePassXC database with a remote KeePassXC database over ssh.

## Instaltion

Before install it, you need to edit the user configuration variables at the top of this script: `scripts/keepassxc-sync-cli.bash`.

Then run:
```bash
 $ ./install.sh
```

If you need to change the configuration after the installation, you can re-install it or directly edit the script at `/opt/keepassxc-sync/scripts/keepassxc-sync-cli.sh`

Note: This installation procedure was tested with KeePassXC 2.5.4 and Ubuntu 18.04.

## Usage

### keepassxc-sync-cli

This command will simply synchronize your local database with the remote database according your settings.
```bash
 $ keepassxc-sync-cli
```

### keepassxc-sync

This command will synchronize your databases, then run `keepassxc` and when exit re-synchronize your databases.
```bash
 $ keepassxc-sync
```

This command is also install as an application, so instead of run `KeePass XC` directly run `KeePass XC sync`.
