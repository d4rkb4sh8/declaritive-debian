#!/bin/bash

# Set the backup directory path
BACKUP_DIR="$HOME/backup"

# Set the config file path
CONFIG_FILE="system-declaration.cfg"

# Create backup directory if it doesn't exist
create_backup_dir() {
    [ ! -d "$BACKUP_DIR" ] && mkdir -p "$BACKUP_DIR"
}

# Backup current config
backup_system_state() {
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp "$CONFIG_FILE" "$BACKUP_DIR/system-declaration_$TIMESTAMP.cfg"
    echo "Backup saved at $BACKUP_DIR/system-declaration_$TIMESTAMP.cfg"
}

#Backup .bashrc
if [ -f "$HOME/.bashrc" ]; then
    cp $HOME/.bashrc $BACKUP_DIR/.bashrc_$TIMESTAMP
    echo "Backed up .bashrc to $BACKUP_DIR/.bashrc_$TIMESTAMP"
else
    echo ".bashrc does not exist, no backup created."
fi

# Backup .bash_aliases
if [ -f "$HOME/.bash_aliases" ]; then
    cp $HOME/.bash_aliases $BACKUP_DIR/.bash_aliases_$TIMESTAMP
    echo "Backed up .bash_aliases to $BACKUP_DIR/.bash_aliases_$TIMESTAMP"
else
    echo ".bash_aliases does not exist, no backup created."
fi

# Initialize config file if it doesn't exist
initialize_config_file() {
    if [ ! -f "$CONFIG_FILE" ]; then
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
    fi
}

# Load the config file
load_config_file() {
    # Check if config file exists before sourcing
    [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
}

# Helper function to check if a package is installed (for apt and dpkg)
is_package_installed() {
    dpkg -l | grep -qw "$1"
}

# Detect installed packages
detect_packages() {
    # Detect apt-installed and dpkg packages
    installed_apt_packages=$(dpkg-query -W -f='${binary:Package}=${Version}\n')

    # Detect installed flatpaks
    if command -v flatpak &> /dev/null; then
        installed_flatpaks=$(flatpak list --app --columns=application)
    else
        installed_flatpaks=""
    fi

    # Detect installed snaps
    if command -v snap &> /dev/null; then
        installed_snaps=$(snap list | awk 'NR>1 {print $1"="$2}')
    else
        installed_snaps=""
    fi

    # Detect installed Homebrew formulas
    if command -v brew &> /dev/null; then
        installed_brew_formulas=$(brew list)
    else
        installed_brew_formulas=""
    fi
}

# Update the config file with detected packages
update_config_file_with_packages() {
    # Replace packages_install, flatpak_install, snap_install, and homebrew_formulas
    sed -i -e '/^packages_install=(/,+1d' \
           -e '/^flatpak_install=(/,+1d' \
           -e '/^snap_install=(/,+1d' \
           -e '/^homebrew_formulas=(/,+1d' "$CONFIG_FILE"
    
    {
        echo "packages_install=("
        echo "$installed_apt_packages" | while IFS== read -r pkg ver; do
            echo "    \"$pkg=$ver\""
        done
        echo ")"

        echo "flatpak_install=("
        echo "$installed_flatpaks" | while read -r pkg; do
            echo "    \"$pkg\""
        done
        echo ")"

        echo "snap_install=("
        echo "$installed_snaps" | while IFS== read -r pkg ver; do
            echo "    \"$pkg=$ver\""
        done
        echo ")"

        echo "homebrew_formulas=("
        echo "$installed_brew_formulas" | while read -r formula; do
            echo "    \"$formula\""
        done
        echo ")"
    } >> "$CONFIG_FILE"
}

# Install packages from the config
install_packages() {
    # Update package lists
    sudo apt-get update

    # Install apt/dpkg packages
    for package in "${packages_install[@]}"; do
        pkg_name=$(echo $package | cut -d '=' -f 1)
        if is_package_installed "$pkg_name"; then
            echo "$pkg_name is already installed."
        else
            sudo apt-get install -y "$pkg_name"
        fi
    done

    # Install flatpak packages
    for package in "${flatpak_install[@]}"; do
        flatpak install -y "$package"
    done

    # Install snap packages
    for package in "${snap_install[@]}"; do
        snap install "$package"
    done

    # Install Homebrew formulas
    for formula in "${homebrew_formulas[@]}"; do
        brew install "$formula"
    done
}

# Main function
main() {
    create_backup_dir
    initialize_config_file
    load_config_file
    detect_packages
    update_config_file_with_packages
    backup_system_state
    install_packages
    echo "System configuration applied successfully!"
}

# Entry point
main "$@" && notify-send "success" || notify-send "failed"

