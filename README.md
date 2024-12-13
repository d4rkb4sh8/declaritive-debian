⣾  Loading⣽  Loading⣻  Loading⢿  Loading⡿  Loading⣟  Loading⣯  Loading⣷  Loading          
Here's the rewritten content in Markdown format:

```markdown
# backup_system.sh

## NAME

backup_system.sh - Backup and restore system packages and configurations

## SYNOPSIS

```
backup_system.sh [options]
``

## DESCRIPTION

backup_system.sh is a script to backup and restore installed packages and configuration files on a Debian system.

## OPTIONS

### -a, --aptBackup apt packages

### -b, --brewBackup homebrew packages

### -f, --flatpakBackup flatpak packages

### -s, --snapBackup snap packages

### -g, --gnomeBackup GNOME configuration

### -t, --terminalBackup terminal configuration

### -n, --nvimBackup nvim configuration

### -c, --configBackup .config folder

### -A, --allBackup all packages and configurations

### -r, --restore Restore system based on the .cfg file

### -h, --help Display this help message

## EXAMPLES

```
./backup_system.sh --all
./backup_system.sh --apt --brew --gnome
./backup_system.sh --restore
``

## AUTHOR

Written by [Your Name]

## COPYRIGHT

Copyright (co 2023 [Your Name]. License: MIT

## SEE ALSO

apt(8), brew(1), flatpak(1), snap(1)
```

