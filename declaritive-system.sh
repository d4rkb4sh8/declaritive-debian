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

# Backup a file
backup_file() {
    local file="$1"
    local backup_name="$2"
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/$backup_name_$TIMESTAMP"
        echo "Backed up $file to $BACKUP_DIR/$backup_name_$TIMESTAMP"
    else
        echo "$file does not exist, no backup created."
    fi
}

# Initialize config file if it doesn't exist
initialize_config_file() {
    if [ ! -f "$CONFIG_FILE" ]; then
        cat <<EOF > "$CONFIG_FILE"
# System Declaration Config

# Installed apt/dpkg packages
packages_install=()

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

    # Detect installed Homebrew formulas
    if command -v brew &> /dev/null; then
        installed_brew_formulas=$(brew list)
    else
        installed_brew_formulas=""
    fi
}

# Update the config file with detected packages
update_config_file_with_packages() {
    # Replace packages_install and homebrew_formulas
    sed -i -e '/^packages_install=(/,+1d' \
           -e '/^homebrew_formulas=(/,+1d' "$CONFIG_FILE"
    
    {
        echo "packages_install=("
        echo "$installed_apt_packages" | while IFS== read -r pkg ver; do
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
        pkg_name=$(echo "$package" | cut -d '=' -f 1)
        if is_package_installed "$pkg_name"; then
            echo "$pkg_name is already installed."
        else
            sudo apt-get install -y "$pkg_name"
        fi
    done

    # Install Homebrew formulas
    for formula in "${homebrew_formulas[@]}"; do
        brew install "$formula"
    done
}

# Remove entries from the config file if a package is removed
remove_config_entries() {
    # Remove apt/dpkg packages
    for package in "${packages_install[@]}"; do
        pkg_name=$(echo "$package" | cut -d '=' -f 1)
        if ! is_package_installed "$pkg_name"; then
            sed -i "/$pkg_name/d" "$CONFIG_FILE"
        fi
    done

    # Remove Homebrew formulas
    for formula in "${homebrew_formulas[@]}"; do
        if ! brew list | grep -qw "$formula"; then
            sed -i "/$formula/d" "$CONFIG_FILE"
        fi
    done
}

# Build a new system from an existing config file
build_new_system() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        install_packages
        echo "New system built successfully from existing configuration file!"
    else
        echo "Configuration file does not exist. Please create one first."
    fi
}

# Main function
main() {
    create_backup_dir
    initialize_config_file
    load_config_file
    detect_packages
    update_config_file_with_packages
    backup_system_state
    backup_file "$HOME/.bashrc" ".bashrc"
    backup_file "$HOME/.bash_aliases" ".bash_aliases"
    install_packages
    remove_config_entries
    echo "System configuration applied successfully!"
}

# Entry point
if [ "$1" == "--build" ]; then
    build_new_system
else
    main "$@"
fi
