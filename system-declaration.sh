#!/bin/bash

# Set the backup directory path
BACKUP_DIR="$HOME/backup"

# Set the config file path
CONFIG_FILE="system-declaration.cfg"

# Set the log file path
LOG_FILE="$BACKUP_DIR/system-declaration.log"

# Create backup directory if it doesn't exist
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Creating backup directory at $BACKUP_DIR..."
        mkdir -p "$BACKUP_DIR"
    fi
}

# Backup current config
backup_system_state() {
    echo "Backing up current system state..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp "$CONFIG_FILE" "$BACKUP_DIR/system-declaration_$TIMESTAMP.cfg"
    echo "Backup saved at $BACKUP_DIR/system-declaration_$TIMESTAMP.cfg"
}

# Initialize config file if it doesn't exist
initialize_config_file() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Creating new configuration file at $CONFIG_FILE..."
        cat <<EOF > "$CONFIG_FILE"
# System Declaration Config

# Installed apt/dpkg packages
packages_install=()

# Installed flatpaks
flatpak_install=()

# Installed snaps
snap_install=()

# Installed Homebrew formulas
homebrew_formulas=()

# Services, custom commands, etc.
EOF
        echo "Configuration file created."
    else
        echo "Configuration file $CONFIG_FILE already exists."
    fi
}

# Load the config file
load_config_file() {
    source "$CONFIG_FILE"
}

# Helper function to check if a package is installed (for apt and dpkg)
is_package_installed() {
    dpkg -l | grep -q "^ii  $1\s"
}

# Detect apt-installed and dpkg packages (including version numbers)
detect_apt_packages() {
    echo "Detecting apt and dpkg installed packages..."
    installed_apt_packages=$(dpkg-query -W -f='${binary:Package}=${Version}\n')
    echo "Found the following apt/dpkg packages:"
    echo "$installed_apt_packages"
}

# Detect installed flatpaks
detect_flatpak_packages() {
    if command -v flatpak &> /dev/null; then
        echo "Detecting flatpak packages..."
        installed_flatpaks=$(flatpak list --columns=application,version | awk '{print $1"="$2}')
        echo "Found the following flatpak packages:"
        echo "$installed_flatpaks"
    else
        echo "Flatpak is not installed."
        installed_flatpaks=""
    fi
}

# Detect installed snaps
detect_snap_packages() {
    if command -v snap &> /dev/null; then
        echo "Detecting snap packages..."
        installed_snaps=$(snap list | awk 'NR>1 {print $1"="$2}')
        echo "Found the following snap packages:"
        echo "$installed_snaps"
    else
        echo "Snap is not installed."
        installed_snaps=""
    fi
}

# Detect installed Homebrew formulas
detect_homebrew_packages() {
    if command -v brew &> /dev/null; then
        echo "Detecting Homebrew formulas..."
        installed_brew_formulas=$(brew list)
        echo "Found the following Homebrew formulas:"
        echo "$installed_brew_formulas"
    else
        echo "Homebrew is not installed."
        installed_brew_formulas=""
    fi
}

# Update the config file with detected packages
update_config_file_with_packages() {
    echo "Updating the configuration file with detected system packages..."

    # Add apt/dpkg packages with versions
    sed -i '/^packages_install=(/,$d' "$CONFIG_FILE"
    echo "packages_install=(" >> "$CONFIG_FILE"
    for package in $installed_apt_packages; do
        echo "    \"$package\"" >> "$CONFIG_FILE"
    done
    echo ")" >> "$CONFIG_FILE"

    # Add flatpak packages with versions
    echo "flatpak_install=(" >> "$CONFIG_FILE"
    for package in $installed_flatpaks; do
        echo "    \"$package\"" >> "$CONFIG_FILE"
    done
    echo ")" >> "$CONFIG_FILE"

    # Add snap packages with versions
    echo "snap_install=(" >> "$CONFIG_FILE"
    for package in $installed_snaps; do
        echo "    \"$package\"" >> "$CONFIG_FILE"
    done
    echo ")" >> "$CONFIG_FILE"

    # Add Homebrew formulas
    echo "homebrew_formulas=(" >> "$CONFIG_FILE"
    for package in $installed_brew_formulas; do
        echo "    \"$package\"" >> "$CONFIG_FILE"
    done
    echo ")" >> "$CONFIG_FILE"

    echo "Configuration file updated with detected packages."
}

# Save the current system state
save_system_state() {
    echo "Saving current system state..."
    detect_apt_packages
    detect_flatpak_packages
    detect_snap_packages
    detect_homebrew_packages
    update_config_file_with_packages
    backup_system_state
    echo "System state saved successfully."
}

# Restore the system state from a backup
restore_system_state() {
    if [ -z "$1" ]; then
        echo "Error: No backup file specified."
        exit 1
    fi

    if [ ! -f "$1" ]; then
        echo "Error: Backup file $1 does not exist."
        exit 1
    fi

    echo "Restoring system state from $1..."
    cp "$1" "$CONFIG_FILE"
    load_config_file

    # Install packages from apt
    echo "Installing apt/dpkg packages..."
    for package in "${packages_install[@]}"; do
        if is_package_installed "$(echo $package | cut -d '=' -f 1)"; then
            echo "$package is already installed."
        else
            echo "Installing $package..."
            sudo apt-get install -y "$package"
        fi
    done

    # Install flatpak packages
    echo "Installing flatpak packages..."
    for package in "${flatpak_install[@]}"; do
        flatpak install -y "$package"
    done

    # Install snap packages
    echo "Installing snap packages..."
    for package in "${snap_install[@]}"; do
        snap install "$package"
    done

    # Install Homebrew formulas
    echo "Installing Homebrew formulas..."
    for formula in "${homebrew_formulas[@]}"; do
        brew install "$formula"
    done

    echo "System state restored successfully."
}

# Incremental backup
incremental_backup() {
    echo "Performing incremental backup..."
    LAST_BACKUP=$(ls -t "$BACKUP_DIR"/system-declaration_*.cfg | head -n 1)
    if [ -z "$LAST_BACKUP" ]; then
        echo "No previous backup found. Performing full backup."
        backup_system_state
    else
        echo "Comparing current state with $LAST_BACKUP..."
        diff "$CONFIG_FILE" "$LAST_BACKUP" > /dev/null
        if [ $? -eq 0 ]; then
            echo "No changes detected. No backup needed."
        else
            backup_system_state
        fi
    fi
}

# Help section
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --save                Save the current system state."
    echo "  --restore <file>      Restore the system state from a backup file."
    echo "  --incremental         Perform an incremental backup."
    echo "  --help                Show this help message."
    echo "  --man                 Show manpage-like description."
}

# Manpage-like description
show_manpage() {
    echo "NAME"
    echo "    system-declaration - Declarative system configuration and backup tool"
    echo ""
    echo "SYNOPSIS"
    echo "    system-declaration [options]"
    echo ""
    echo "DESCRIPTION"
    echo "    This script allows you to save, restore, and manage system configurations in a declarative manner."
    echo "    It supports saving and restoring packages installed via apt, flatpak, snap, and Homebrew."
    echo ""
    echo "OPTIONS"
    echo "    --save"
    echo "        Save the current system state, including installed packages and configurations."
    echo ""
    echo "    --restore <file>"
    echo "        Restore the system state from a specified backup file."
    echo ""
    echo "    --incremental"
    echo "        Perform an incremental backup, only saving changes since the last backup."
    echo ""
    echo "    --help"
    echo "        Display this help message."
    echo ""
    echo "    --man"
    echo "        Display a manpage-like description of the script."
    echo ""
    echo "EXAMPLES"
    echo "    Save the current system state:"
    echo "        $0 --save"
    echo ""
    echo "    Restore the system state from a backup file:"
    echo "        $0 --restore ~/backup/system-declaration_20231001_120000.cfg"
    echo ""
    echo "    Perform an incremental backup:"
    echo "        $0 --incremental"
    echo ""
    echo "AUTHOR"
    echo "    Written by [d4rkb4sh8]"
    echo ""
    echo "REPORTING BUGS"
    echo "    Report bugs to [https://github.com/d4rkb4sh8/declaritive-debian]"
    echo ""
    echo "COPYRIGHT"
    echo "    Copyright © 2023 [d4rkb4sh8] License [Open Source/GNU/Public License]"
    echo "    This is free software: you are free to change and redistribute it."
    echo "    There is NO WARRANTY, to the extent permitted by law."
}

# Main function
main() {
    create_backup_dir
    initialize_config_file

    case "$1" in
        --save)
            save_system_state
            ;;
        --restore)
            if [ -z "$2" ]; then
                echo "Error: No backup file specified."
                exit 1
            fi
            restore_system_state "$2"
            ;;
        --incremental)
            incremental_backup
            ;;
        --help)
            show_help
            ;;
        --man)
            show_manpage
            ;;
        *)
            echo "Invalid option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Entry point
main "$@"
