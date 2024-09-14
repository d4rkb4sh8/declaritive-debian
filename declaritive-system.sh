#!/bin/bash

# Define paths and backup directory
CONFIG_FILE="$HOME/config_packages.txt"
BACKUP_DIR="$HOME/backups"
CURRENT_TIME=$(date +"%Y%m%d_%H%M%S")

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Function to get packages from dpkg and apt
get_dpkg_apt_packages() {
    echo "Getting dpkg and apt packages..."
    sudo dpkg-query -l > /tmp/dpkg_list.txt
    sudo apt list --installed > /tmp/apt_list.txt
    cat /tmp/dpkg_list.txt /tmp/apt_list.txt | awk '/^ii/ {print $2}' > /tmp/all_packages.txt
}

# Function to get packages from flatpak
get_flatpak_packages() {
    echo "Getting flatpak packages..."
    flatpak list --installed > /tmp/flatpak_list.txt
    awk '{print $1}' /tmp/flatpak_list.txt > /tmp/all_packages.txt
}

# Function to get packages from snap
get_snap_packages() {
    echo "Getting snap packages..."
    snap list > /tmp/snap_list.txt
    awk '{print $1}' /tmp/snap_list.txt >> /tmp/all_packages.txt
}

# Function to get packages from homebrew
get_homebrew_packages() {
    echo "Getting homebrew packages..."
    brew list > /tmp/homebrew_list.txt
    cat /tmp/homebrew_list.txt >> /tmp/all_packages.txt
}

# Main function to update the config file and handle backups
update_config_file() {
    echo "Updating configuration file..."
    get_dpkg_apt_packages
    get_flatpak_packages
    get_snap_packages
    get_homebrew_packages

    sort -u /tmp/all_packages.txt > $CONFIG_FILE
    rm /tmp/all_packages.txt

    # Create a backup of the previous config file
    cp $CONFIG_FILE ${BACKUP_DIR}/config_packages_${CURRENT_TIME}.bak
}

# Check if the config file exists and is not empty, otherwise create it
if [ ! -s "$CONFIG_FILE" ]; then
    echo "Config file does not exist or is empty. Initializing..."
    update_config_file
else
    # Compare current packages with the config file to detect changes
    get_dpkg_apt_packages
    get_flatpak_packages
    get_snap_packages
    get_homebrew_packages

    sort -u /tmp/all_packages.txt > /tmp/current_packages.txt
    rm /tmp/all_packages.txt

    if diff /tmp/current_packages.txt $CONFIG_FILE > /dev/null; then
        echo "No changes detected."
    else
        update_config_file
    fi
fi

echo "Configuration file updated and backed up successfully."
