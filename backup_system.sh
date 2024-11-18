#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Define backup directory in the user's home directory
USER_HOME=$(eval echo ~${SUDO_USER})
BACKUP_DIR="$USER_HOME/system_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Function to display help message
display_help() {
  echo "Usage: backup_system.sh [options]"
  echo "Options:"
  echo "  -a, --apt        Backup apt packages"
  echo "  -b, --brew       Backup homebrew packages"
  echo "  -f, --flatpak    Backup flatpak packages"
  echo "  -s, --snap       Backup snap packages"
  echo "  -g, --gnome      Backup GNOME configuration"
  echo "  -t, --terminal   Backup terminal configuration"
  echo "  -n, --nvim       Backup nvim configuration"
  echo "  -c, --config     Backup .config folder"
  echo "  -A, --all        Backup all packages and configurations"
  echo "  -h, --help       Display this help message"
  exit 0
}

# Function to backup apt packages
backup_apt_packages() {
  echo "Backing up apt packages..."
  dpkg --get-selections > "$BACKUP_DIR/apt_packages.txt"
}

# Function to backup homebrew packages
backup_homebrew_packages() {
  echo "Backing up homebrew packages..."
  if command -v brew &> /dev/null; then
    brew list --formula > "$BACKUP_DIR/homebrew_packages.txt"
    brew list --cask > "$BACKUP_DIR/homebrew_casks.txt"
  else
    echo "Homebrew not found, skipping."
  fi
}

# Function to backup flatpak packages
backup_flatpak_packages() {
  echo "Backing up flatpak packages..."
  flatpak list --app --columns=application > "$BACKUP_DIR/flatpak_packages.txt"
}

# Function to backup snap packages
backup_snap_packages() {
  echo "Backing up snap packages..."
  snap list > "$BACKUP_DIR/snap_packages.txt"
}

# Function to backup GNOME configuration
backup_gnome_config() {
  echo "Backing up GNOME configuration..."
  dconf dump / > "$BACKUP_DIR/gnome_settings.dconf"
}

# Function to backup terminal configuration
backup_terminal_config() {
  echo "Backing up terminal configuration..."
  cp -r "$USER_HOME/.bashrc" "$BACKUP_DIR/"
  cp -r "$USER_HOME/.zshrc" "$BACKUP_DIR/" 2>/dev/null
}

# Function to backup nvim configuration
backup_nvim_config() {
  echo "Backing up nvim configuration..."
  cp -r "$USER_HOME/.config/nvim" "$BACKUP_DIR/"
}

# Function to backup .config folder
backup_config_folder() {
  echo "Backing up .config folder..."
  cp -r "$USER_HOME/.config" "$BACKUP_DIR/"
}

# Function to run all backup functions
backup_all() {
  backup_apt_packages
  backup_homebrew_packages
  backup_flatpak_packages
  backup_snap_packages
  backup_gnome_config
  backup_terminal_config
  backup_nvim_config
  backup_config_folder
}

# Main function to parse options and run backup functions
main() {
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -a|--apt) backup_apt_packages; shift ;;
      -b|--brew) backup_homebrew_packages; shift ;;
      -f|--flatpak) backup_flatpak_packages; shift ;;
      -s|--snap) backup_snap_packages; shift ;;
      -g|--gnome) backup_gnome_config; shift ;;
      -t|--terminal) backup_terminal_config; shift ;;
      -n|--nvim) backup_nvim_config; shift ;;
      -c|--config) backup_config_folder; shift ;;
      -A|--all) backup_all; shift ;;
      -h|--help) display_help; shift ;;
      *) echo "Unknown parameter passed: $1"; display_help; shift ;;
    esac
    shift
  done

  echo "Backup completed successfully. Files saved in $BACKUP_DIR"
}

# Run the main function with provided arguments
main "$@"

