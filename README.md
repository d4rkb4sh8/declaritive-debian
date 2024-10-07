Steps:
    chmod +x system-declaration.sh

Usage:

    Save: ./system-declaration.sh --save

    Restore: ./system-declaration.sh --restore ~/backup/system-declaration_20231001_120000.cfg

    Incremental Backup: ./system-declaration.sh --incremental

    Help: ./system-declaration.sh --help

    Manpage: ./system-declaration.sh --man




Key Changes:

    remove_config_entries Function: This function checks if a package is no longer installed and removes its entry from the system-declaration.cfg file.

    build_new_system Function: This function allows building a new system from an existing configuration file. It is triggered by the --build flag.

    Entry Point: The script now checks for the --build flag to determine whether to build a new system or run the main function.

This version ensures that the system-declaration.cfg file always accurately reflects the current state of the system, and it provides a way to build a new system from an existing configuration file.


