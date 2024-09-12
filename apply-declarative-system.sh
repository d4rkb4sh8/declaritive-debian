#!/bin/bash

# Set the backup directory path
BACKUP_DIR="$HOME/backup"

# Set the config file path
CONFIG_FILE="system-declaration.cfg"

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
        installed_flatpaks=$(flatpak list --app --columns=application)
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

    # Add flatpak packages
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

# Main function
main() {
    # Ensure backup directory exists
    create_backup_dir

    # Initialize config file if it doesn't exist
    initialize_config_file

    # Load the existing configuration
    load_config_file

    # Detect all types of packages and update the configuration file
    detect_apt_packages
    detect_flatpak_packages
    detect_snap_packages
    detect_homebrew_packages

    # Update the config file with the detected packages
    update_config_file_with_packages

    # Backup the current state of the configuration
    backup_system_state

    # Update package lists
    echo "Updating package lists..."
    sudo apt-get update

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

    echo "System configuration applied successfully!"
}

# Entry point
main "$@"

