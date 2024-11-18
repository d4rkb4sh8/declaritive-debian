#!/bin/bash

# Enhanced System Declaration & Backup Utility with Timeshift and GRUB Integration
# Author: [d4rkb4sh8]

BACKUP_DIR="$HOME/backup"
CONFIG_FILE="system-declaration.cfg"
LOG_FILE="$BACKUP_DIR/system-declaration.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Error handling function
error_exit() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE"
    exit 1
}

# Check if Timeshift is installed
check_timeshift() {
    if ! command -v timeshift &> /dev/null; then
        error_exit "Timeshift is not installed. Please install it using: sudo apt install timeshift"
    fi
}

# Create a system snapshot using Timeshift and update GRUB
create_snapshot() {
    SNAPSHOT_LABEL="system_snapshot_$TIMESTAMP"
    echo "Creating system snapshot with Timeshift: $SNAPSHOT_LABEL"
    
    # Create snapshot using Timeshift in RSYNC mode (compatible with EXT4)
    sudo timeshift --create --comments "$SNAPSHOT_LABEL" --tags D || error_exit "Failed to create snapshot."
    
    echo "Snapshot created successfully with label: $SNAPSHOT_LABEL"

    # Update GRUB configuration to include the new snapshot
    update_grub
}

# Update GRUB configuration to include Timeshift snapshots
update_grub() {
    echo "Updating GRUB configuration to include Timeshift snapshots..."
    
    # Ensure the Timeshift GRUB integration is enabled
    if [ -f /etc/default/grub ]; then
        sudo sed -i 's/#GRUB_DISABLE_RECOVERY="true"/GRUB_DISABLE_RECOVERY="false"/g' /etc/default/grub
        sudo sed -i 's/#GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=n/g' /etc/default/grub
    fi
    
    # Regenerate GRUB configuration
    sudo update-grub || error_exit "Failed to update GRUB."
    echo "GRUB configuration updated successfully. Snapshots should appear in the GRUB menu."
}

# List available snapshots using Timeshift
list_snapshots() {
    echo "Listing available snapshots..."
    sudo timeshift --list || echo "No snapshots found."
}

# Restore a snapshot using Timeshift
restore_snapshot() {
    local snapshot_name="$1"
    echo "Restoring snapshot: $snapshot_name"
    
    # Perform restoration using Timeshift
    sudo timeshift --restore --snapshot "$snapshot_name" || error_exit "Failed to restore snapshot $snapshot_name."
    
    echo "Snapshot $snapshot_name restored successfully. Please reboot the system."
}

# Backup current configuration and state
backup_system_state() {
    echo "Backing up current system state..."
    cp "$CONFIG_FILE" "$BACKUP_DIR/system-declaration_$TIMESTAMP.cfg" || error_exit "Failed to copy configuration file."
    echo "Backup saved at $BACKUP_DIR/system-declaration_$TIMESTAMP.cfg"
}

# Enhanced help message
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --save            Save the current system state and create a Timeshift snapshot."
    echo "  --restore <name>  Restore a specific Timeshift snapshot."
    echo "  --list            List all available Timeshift snapshots."
    echo "  --help            Display this help message."
}

# Main function
main() {
    check_timeshift

    case "$1" in
        --save)
            backup_system_state
            create_snapshot
            ;;
        --restore)
            if [ -z "$2" ]; then
                error_exit "No snapshot specified for restoration."
            fi
            restore_snapshot "$2"
            ;;
        --list)
            list_snapshots
            ;;
        --help)
            show_help
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
