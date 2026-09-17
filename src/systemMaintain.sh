#!/bin/sh
set -e

# 🎛️ Parse command-line arguments
AUTO_YES=0
for arg in "$@"; do
    if [ "$arg" = "-y" ] || [ "$arg" = "--yes" ]; then
        AUTO_YES=1
    fi
done

# 👀 Detect environment
if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
    ENV="termux"
elif [ -f /etc/debian_version ]; then
    ENV="debian"
else
    echo "😅 oH oops! sorry I dont support this system ! sorry!"
    exit 1
fi

if [ "$ENV" = "termux" ]; then
    echo "📲 [+] okay its termux now?"
    
    echo "✨ ==> Updating package "
    pkg update -y

    echo "⚡ ==> Upgrading packages..."
    pkg upgrade -y

    echo "🩹 ==> Repairing broken dependencies..."
    dpkg --configure -a
    apt-get install -f -y

    echo "🔍 ==> Running system check..."
    apt-get check

    echo "🧹 ==> Cleaning package cache..."
    pkg autoclean

else
    echo "🐧 [+] Debian/Ubuntu detected. Running system maintenance..."

    # 🛑 Ensure root/sudo privileges
    if [ "$(id -u)" -ne 0 ]; then
        echo "✋ Error: Please run this script with root privileges (e.g., sudo ./systemMaintain.sh)"
        exit 1
    fi

    echo "✨ ==> Updating package lists..."
    apt-get update -y

    echo "🚀 ==> Performing system upgrade..."
    apt-get dist-upgrade -y

    echo "🩹 ==> Repairing broken packages & dependencies..."
    dpkg --configure -a
    apt-get install -f -y

    echo "🔍 ==> Checking package integrity..."
    apt-get check

    echo "🗑️ ==> Removing orphaned packages..."
    apt-get autoremove -y --purge

    echo "🧹 ==> Clearing package caches..."
    apt-get autoclean -y
    apt-get clean -y

    # 📦 Clear old system logs via systemd if available
    if command -v journalctl >/dev/null 2>&1; then
        echo "⚠️ ==> CAUTION VACUMMING SYSTEMD JOURNAL PLEASE REVIEW !!!!!!!!!"
        
        PERFORM_VACUUM=0
        if [ "$AUTO_YES" -eq 1 ]; then
            PERFORM_VACUUM=1
        else
            printf "🤔 Do you want to clear systemd journal logs older than 7 days? [y/N]: "
            read -r RESPONSE
            case "$RESPONSE" in
                [yY][eE][sS]|[yY])
                    PERFORM_VACUUM=1
                    ;;
                *)
                    echo "✌️ Skipping journal vacuuming."
                    ;;
            esac
        fi

        if [ "$PERFORM_VACUUM" -eq 1 ]; then
            echo "🧹 Vacuuming logs older than 7 days..."
            journalctl --vacuum-time=7d
        fi
    fi
fi

echo "🔥 [✔] Maintenance and system repairs completed successfully."
