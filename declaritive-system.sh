#!/bin/bash

# Configuration
BACKUP_DIR="/home/h4ck3r/backup"
declare -A PACKAGE_MANAGERS # Associative array to store package managers
PACKAGE_MANAGERS=( ["dpkg"]="dpkg -l" ["apt"]="apt list --installed" ["brew"]="brew list" ["flatpak"]="flatpak list" ["snap"]="snap list")
CONFIG_FILES=(".bashrc" ".bash_aliases") # List of config files to backup

# Ensure BACKUP_DIR exists
mkdir -p $BACKUP_DIR

# Function to create a timestamped backup
function create_backup {
    local file=$1
    cp $file "$BACKUP_DIR/${file}_$(date +%F_%H-%M-%S)"
}

# Main function to manage backups and config files
function manage_configs {
    for manager in "${!PACKAGE_MANAGERS[@]}"; do
        echo "Checking installed packages with $manager..."
        # Get list of installed packages from each package manager
        pkgs=$(${PACKAGE_MANAGERS[$manager]})
        
        while read -r pkg; do
            if [[ -z $(grep "^$pkg" "$BACKUP_DIR/${file}_backup.log") ]]; then
                echo "Package $pkg detected."
                create_backup $file
            fi
        done <<< "$(echo "$pkgs" | grep -E '^(ii|i)'"\t")" # Filter lines that match installed packages
    done
}

# Function to clean up old backups
function cleanup_backups {
    local count=$(ls -1 $BACKUP_DIR/*.log 2>/dev/null | wc -l)
    if [[ $count -gt 5 ]]; then
        ls -tr $BACKUP_DIR/*.log | head -n $(($count-5)) | xargs rm -f
    fi
}

# Main script execution
for file in "${CONFIG_FILES[@]}"; do
    manage_configs $file
done
cleanup_backups
