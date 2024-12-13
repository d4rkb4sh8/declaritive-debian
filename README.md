
# backup_system.sh

## NAME
**backup_system.sh** - Backup and restore system packages and configurations

## SYNOPSIS
```bash
backup_system.sh [options]
```

## DESCRIPTION
**backup_system.sh** is a script to back up and restore installed packages and configuration files on a Debian system.

## OPTIONS

- **-a, --aptBackup**: Backup apt packages  
- **-b, --brewBackup**: Backup Homebrew packages  
- **-f, --flatpakBackup**: Backup Flatpak packages  
- **-s, --snapBackup**: Backup Snap packages  
- **-g, --gnomeBackup**: Backup GNOME configuration  
- **-t, --terminalBackup**: Backup terminal configuration  
- **-n, --nvimBackup**: Backup nvim configuration  
- **-c, --configBackup**: Backup `.config` folder  
- **-A, --allBackup**: Backup all packages and configurations  
- **-r, --restore**: Restore the system based on the `.cfg` file  
- **-h, --help**: Display this help message  

## EXAMPLES
```bash
./backup_system.sh --all
./backup_system.sh --apt --brew --gnome
./backup_system.sh --restore
```

## AUTHOR
Written by [Your Name]

## COPYRIGHT
Copyright © 2023 [Your Name]. License: MIT.

## SEE ALSO
- `apt(8)`
- `brew(1)`
- `flatpak(1)`
- `snap(1)`
