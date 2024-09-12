Pros:

    Comprehensive System Capture: All installed software, regardless of installation method, is tracked and added to the configuration file.
    Reproducibility: Every package, including flatpaks and snaps, can be installed on another machine to replicate the system environment.
    Cross-Package Format Management: Supports different types of packaging systems used on Debian, making the solution more flexible.

Cons:

    Flatpak/Snap Installation: Replicating packages across systems may require flatpak or snap to be installed manually before applying the configuration.
    Snap/Flatpak Versions: Managing version locking for these formats is not as straightforward as for apt and .deb packages.

Changes:

    Detection Functions:
        detect_apt_packages: Detects all installed apt and dpkg packages, including their versions.
        detect_flatpak_packages: Detects all installed Flatpak apps.
        detect_snap_packages: Detects all installed Snap apps, including versions.

    Dynamic Config Update:
        The script dynamically updates the configuration file (system-declaration.cfg) to include:
            apt/dpkg packages with versions.
            Removed packages.
            Installed flatpaks.
            Installed snaps with versions.

    Install Flatpaks & Snaps:
        The script installs packages from Flatpak and Snap in addition to apt packages.


Key Enhancements:

    Version Locking:
        The packages_install array now includes specific versions for each package, ensuring version consistency across systems.

    Backup & Rollback:
        The script creates a snapshot of the system before applying changes, storing it in a time-stamped directory defined by backup_dir.
        The rollback_system_state function allows rolling back to any saved state by passing the backup directory as an argument.

    Example:

    bash

    sudo bash apply-declarative-system.sh rollback /path/to/backup/YYYY-MM-DD_HH-MM-SS

    Dynamic Configuration File Updates:
        The script automatically reads the currently installed and removed packages, updates the configuration file (system-declaration.cfg), and locks package versions based on the current system state.

    File Management:
        Files in the files_sync section are backed up and can be restored during rollback.

How to Use:

    Apply Configuration: Run the script to apply system configuration:

    bash

sudo bash apply-declarative-system.sh

Rollback: To roll back the system to a previous state:

bash

    sudo bash apply-declarative-system.sh rollback /path/to/backup/YYYY-MM-DD_HH-MM-SS

This enhanced script should cover most of the declarative, reproducible features found in tools like Nix and Ansible for Debian-based systems.


Key Additions:

    Backup Directory Creation:
        The script creates the backup directory at $HOME/backup if it does not exist.

    First-Time Configuration File Creation:
        The script checks for the existence of system-declaration.cfg. If it doesn't exist, it creates the file and populates it with empty lists for each type of package.

    Config Modification for Future Runs:
        If system-declaration.cfg exists, the script loads it and dynamically updates it based on current installed packages.

    Backups:
        Each time the script is run, it creates a timestamped backup of the system-declaration.cfg file in the $HOME/backup directory.

Backup Directory:

    The backup folder is automatically created under the user's home directory ($HOME/backup).
    Backups of the configuration file are saved with timestamps, ensuring that you can restore a previous system state if necessary.

How to Use:

    First Run:
        On the first run, the script will initialize the system-declaration.cfg and take a snapshot of the current system state.
