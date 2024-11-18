#!/bin/bash

# Define backup directory in the user's home directory
BACKUP_DIR="$HOME/system_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Define the configuration file
CFG_FILE="$BACKUP_DIR/system_backup.cfg"

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
  echo "  -r, --restore    Restore system based on the .cfg file"
  echo "  -h, --help       Display this help message"
  exit 0
}

# Function to backup apt packages
backup_apt_packages() {
  echo "Backing up apt packages..."
  dpkg --get-selections > "$BACKUP_DIR/apt_packages.txt"
  echo "APT_PACKAGES=$BACKUP_DIR/apt_packages.txt" >> "$CFG_FILE"
}

# Function to backup homebrew packages
backup_homebrew_packages() {
  echo "Backing up homebrew packages..."
  if command -v brew &> /dev/null; then
    brew list --formula > "$BACKUP_DIR/homebrew_packages.txt"
    brew list --cask > "$BACKUP_DIR/homebrew_casks.txt"
    echo "HOMEBREW_PACKAGES=$BACKUP_DIR/homebrew_packages.txt" >> "$CFG_FILE"
    echo "HOMEBREW_CASKS=$BACKUP_DIR/homebrew_casks.txt" >> "$CFG_FILE"
  else
    echo "Homebrew not found, skipping."
  fi
}

# Function to backup flatpak packages
backup_flatpak_packages() {
  echo "Backing up flatpak packages..."
  flatpak list --app --columns=application > "$BACKUP_DIR/flatpak_packages.txt"
  echo "FLATPAK_PACKAGES=$BACKUP_DIR/flatpak_packages.txt" >> "$CFG_FILE"
}

# Function to backup snap packages
backup_snap_packages() {
  echo "Backing up snap packages..."
  snap list > "$BACKUP_DIR/snap_packages.txt"
  echo "SNAP_PACKAGES=$BACKUP_DIR/snap_packages.txt" >> "$CFG_FILE"
}

# Function to backup GNOME configuration
backup_gnome_config() {
  echo "Backing up GNOME configuration..."
  dconf dump / > "$BACKUP_DIR/gnome_settings.dconf"
  echo "GNOME_CONFIG=$BACKUP_DIR/gnome_settings.dconf" >> "$CFG_FILE"
}

# Function to backup terminal configuration
backup_terminal_config() {
  echo "Backing up terminal configuration..."
  cp -r "$HOME/.bashrc" "$BACKUP_DIR/"
  cp -r "$HOME/.zshrc" "$BACKUP_DIR/" 2>/dev/null
  echo "TERMINAL_CONFIG=$BACKUP_DIR/.bashrc" >> "$CFG_FILE"
  echo "TERMINAL_CONFIG=$BACKUP_DIR/.zshrc" >> "$CFG_FILE"
}

# Function to backup nvim configuration
backup_nvim_config() {
  echo "Backing up nvim configuration..."
  cp -r "$HOME/.config/nvim" "$BACKUP_DIR/"
  echo "NVIM_CONFIG=$BACKUP_DIR/.config/nvim" >> "$CFG_FILE"
}

# Function to backup .config folder
backup_config_folder() {
  echo "Backing up .config folder..."
  cp -r "$HOME/.config" "$BACKUP_DIR/"
  echo "CONFIG_FOLDER=$BACKUP_DIR/.config" >> "$CFG_FILE"
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

# Function to restore system based on the .cfg file
restore_system() {
  if [ ! -f "$CFG_FILE" ]; then
    echo "Configuration file not found. Please run a backup first."
    exit 1
  fi

  # Source the configuration file
  . "$CFG_FILE"

  # Restore apt packages
  if [ -n "$APT_PACKAGES" ]; then
    echo "Restoring apt packages..."
    sudo dpkg --set-selections < "$APT_PACKAGES"
    sudo apt-get dselect-upgrade -y
  fi

  # Restore homebrew packages
  if [ -n "$HOMEBREW_PACKAGES" ]; then
    echo "Restoring homebrew packages..."
    xargs -a "$HOMEBREW_PACKAGES" brew install
  fi
  if [ -n "$HOMEBREW_CASKS" ]; then
    echo "Restoring homebrew casks..."
    xargs -a "$HOMEBREW_CASKS" brew install --cask
  fi

  # Restore flatpak packages
  if [ -n "$FLATPAK_PACKAGES" ]; then
    echo "Restoring flatpak packages..."
    xargs -a "$FLATPAK_PACKAGES" flatpak install -y
  fi

  # Restore snap packages
  if [ -n "$SNAP_PACKAGES" ]; then
    echo "Restoring snap packages..."
    xargs -a "$SNAP_PACKAGES" snap install
  fi

  # Restore GNOME configuration
  if [ -n "$GNOME_CONFIG" ]; then
    echo "Restoring GNOME configuration..."
    dconf load / < "$GNOME_CONFIG"
  fi

  # Restore terminal configuration
  if [ -n "$TERMINAL_CONFIG" ]; then
    echo "Restoring terminal configuration..."
    cp "$TERMINAL_CONFIG" "$HOME/.bashrc"
    cp "$TERMINAL_CONFIG" "$HOME/.zshrc" 2>/dev/null
  fi

  # Restore nvim configuration
  if [ -n "$NVIM_CONFIG" ]; then
    echo "Restoring nvim configuration..."
    cp -r "$NVIM_CONFIG" "$HOME/.config/nvim"
  fi

  # Restore .config folder
  if [ -n "$CONFIG_FOLDER" ]; then
    echo "Restoring .config folder..."
    cp -r "$CONFIG_FOLDER" "$HOME/.config"
  fi

  echo "System restore completed successfully."
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
      -r|--restore) restore_system; shift ;;
      -h|--help) display_help; shift ;;
      *) echo "Unknown parameter passed: $1"; display_help; shift ;;
    esac
    shift
  done

  echo "Backup completed successfully. Files saved in $BACKUP_DIR"
}

# Run the main function with provided arguments
main "$@"

