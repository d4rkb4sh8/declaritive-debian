**Install: Download and place in $HOME directory**
--------------------------------------------------

download backup\_system.sh

chmod +x backup\_system.sh

mv backup\_system.sh $HOME OR add it to whatever PATH location you like

**Usage: backup\_system.sh \[options\]**
----------------------------------------

Options:

\-a, --apt Backup apt packages

\-b, --brew Backup homebrew packages

\-f, --flatpak Backup flatpak packages

\-s, --snap Backup snap packages

\-g, --gnome Backup GNOME configuration

\-t, --terminal Backup terminal configuration

\-n, --nvim Backup nvim configuration

\-c, --config Backup .config folder

\-A, --all Backup all packages and configurations

\-r, --restore Restore system based on the .cfg file

\-h, --help Display this help message