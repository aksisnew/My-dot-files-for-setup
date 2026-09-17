#!/bin/sh
set -e

# 👀 Detect environment
if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
    ENV="termux"
elif [ -f /etc/debian_version ]; then
    ENV="debian"
else
    echo "😅 oH oops! sorry I dont support this system ! sorry!"
    exit 1
fi

echo "🎨 Select a Color Theme:"
echo "1) Pink & Soft White"
echo "2) Purple & Magenta"
echo "3) Deep Blue & Indigo"
echo "4) Crimson Red & Velvet"
printf "👉 Enter choice [1-4]: "
read -r CHOICE

# Set Color Schemes (No green/cyan, soft dark/neutral backgrounds)
case "$CHOICE" in
    1)
        # Pink & Soft White
        BG="#2B2129"; FG="#F8F0F6"
        C0="#3A2E39"; C1="#F4B8E4"; C2="#F5C2E7"; C3="#FAE3B0"
        C4="#B4BEFE"; C5="#E2B3E8"; C6="#CBA6F7"; C7="#F8F0F6"
        ;;
    2)
        # Purple & Magenta
        BG="#21182B"; FG="#F3E8FF"
        C0="#2E1F3D"; C1="#FF77FF"; C2="#E0A0FF"; C3="#FFB3D9"
        C4="#A077FF"; C5="#D088FF"; C6="#F0A0FF"; C7="#F3E8FF"
        ;;
    3)
        # Deep Blue & Indigo
        BG="#1A1B26"; FG="#C0CAF5"
        C0="#24283B"; C1="#F7768E"; C2="#BB9AF7"; C3="#E0AF68"
        C4="#7AA2F7"; C5="#9D7CD8"; C6="#B4F9F8"; C7="#C0CAF5"
        ;;
    4)
        # Crimson Red & Velvet
        BG="#2A1B1C"; FG="#FDE8E8"
        C0="#3D2224"; C1="#FF5555"; C2="#FF8888"; C3="#FFAAAA"
        C4="#E56B81"; C5="#FF7788"; C6="#FF99AA"; C7="#FDE8E8"
        ;;
    *)
        echo "❌ Invalid choice! Exiting..."
        exit 1
        ;;
esac

if [ "$ENV" = "termux" ]; then
    echo "📲 Applying theme to Termux..."
    
    mkdir -p ~/.termux
    cat <<EOF > ~/.termux/colors.properties
background=$BG
foreground=$FG
color0=$C0
color1=$C1
color2=$C2
color3=$C3
color4=$C4
color5=$C5
color6=$C6
color7=$C7
EOF

    termux-reload-settings || true
    echo "✨ Termux colors updated! Re-open app if colors don't refresh immediately."

else
    echo "🐧 Applying theme ANSI sequences & PS1 prompt for Debian/Ubuntu..."

    # Output escape sequences directly to current terminal session
    printf "\033]10;%s\007" "$FG"
    printf "\033]11;%s\007" "$BG"

    RC_FILE="$HOME/.bashrc"
    [ -f "$HOME/.zshrc" ] && RC_FILE="$HOME/.zshrc"

    # Append prompt customization if not already set
    if ! grep -q "THEME_SH_PROMPT" "$RC_FILE"; then
        cat <<'EOF' >> "$RC_FILE"

# THEME_SH_PROMPT
export PS1="\[\033[1;35m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "
EOF
    fi

    echo "✨ Terminal sequence updated! Run 'source $RC_FILE' to update shell prompt settings."
fi

echo "🔥 [✔] Theme applied successfully!"
