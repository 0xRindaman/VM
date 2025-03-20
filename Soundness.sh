#!/bin/bash

LOG_FILE="$HOME/soundness_log.txt"
echo "Log will be saved to: $LOG_FILE"

install_soundness() {
    echo "Soundness CLI Installation Log - $(date)" > "$LOG_FILE"
    echo "Showing HCA logo..."
    wget -q -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
    curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
    sleep 2

    if [ $(id -u) -eq 0 ]; then
        echo "Updating and upgrading system packages..." | tee -a "$LOG_FILE"
        apt update 2>&1 | tee -a "$LOG_FILE"
        apt upgrade -y 2>&1 | tee -a "$LOG_FILE"
    fi

    echo "Installing Rust and Cargo..." | tee -a "$LOG_FILE"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>&1 | tee -a "$LOG_FILE"
    source "$HOME/.cargo/env"

    echo "Installing Soundness CLI..." | tee -a "$LOG_FILE"
    curl -sSL https://raw.githubusercontent.com/soundnesslabs/soundness-layer/main/soundnessup/install | bash 2>&1 | tee -a "$LOG_FILE"

    echo "Updating PATH..." | tee -a "$LOG_FILE"
    if [ $(id -u) -eq 0 ]; then
        export PATH="$PATH:/root/.soundness/bin"
        [ -f /root/.bashrc ] && source /root/.bashrc
    else
        export PATH="$PATH:$HOME/.soundness/bin"
        [ -f ~/.bashrc ] && source ~/.bashrc
    fi

    echo "Installing CLI components..." | tee -a "$LOG_FILE"
    if command -v soundnessup >/dev/null 2>&1; then
        soundnessup install 2>&1 | tee -a "$LOG_FILE"
    else
        echo "Error: soundnessup not found" | tee -a "$LOG_FILE"
        exit 1
    fi

    if [ $(id -u) -eq 0 ]; then
        KEY_DIR="/root/.soundness/keys"
    else
        KEY_DIR="$HOME/.soundness/keys"
    fi

    echo "Checking for existing keypair 'my-key'..." | tee -a "$LOG_FILE"
    if command -v soundness-cli >/dev/null 2>&1; then
        if soundness-cli list-keys | grep -q "my-key"; then
            echo "Key 'my-key' already exists. Removing it..." | tee -a "$LOG_FILE"
            mkdir -p "$KEY_DIR"
            rm -f "$KEY_DIR/my-key.key" "$KEY_DIR/my-key.pub" 2>&1 | tee -a "$LOG_FILE"
            find "$KEY_DIR" -name "my-key*" -exec rm -f {} \; 2>&1 | tee -a "$LOG_FILE"
            echo "Existing key 'my-key' removed - $(date)" >> "$LOG_FILE"
        else
            echo "No existing 'my-key' found. Proceeding with new key generation..." | tee -a "$LOG_FILE"
        fi
    else
        echo "Error: soundness-cli not found" | tee -a "$LOG_FILE"
        exit 1
    fi

    echo "Generating new key pair..." | tee -a "$LOG_FILE"
    if command -v soundness-cli >/dev/null 2>&1; then
        echo "defaultpass" | soundness-cli generate-key --name my-key 2>&1 | tee -a "$LOG_FILE"
        echo "Key pair generation completed - $(date)" >> "$LOG_FILE"
    else
        echo "Error: soundness-cli not found" | tee -a "$LOG_FILE"
        exit 1
    fi

    echo "Exporting mnemonic phrase..." | tee -a "$LOG_FILE"
    echo "defaultpass" | soundness-cli export-key --name my-key 2>&1 | tee -a "$LOG_FILE"
    echo "Mnemonic export completed - $(date)" >> "$LOG_FILE"

    echo "Subscribe: https://t.me/HappyCuanAirdrop" | tee -a "$LOG_FILE"
    echo "Installation completed. Check $LOG_FILE for details."
}

uninstall_soundness() {
    echo "Soundness CLI Uninstallation Log - $(date)" > "$LOG_FILE"
    echo "Uninstalling Soundness..." | tee -a "$LOG_FILE"

    if [ $(id -u) -eq 0 ]; then
        BASE_DIR="/root"
    else
        BASE_DIR="$HOME"
    fi

    echo "Removing Soundness files..." | tee -a "$LOG_FILE"
    rm -rf "$BASE_DIR/.soundness" 2>&1 | tee -a "$LOG_FILE"
    rm -f "$BASE_DIR/.cargo/bin/soundness-cli" 2>&1 | tee -a "$LOG_FILE"

    echo "Do you want to remove Rust and Cargo? (y/N)" | tee -a "$LOG_FILE"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Removing Rust and Cargo..." | tee -a "$LOG_FILE"
        rustup self uninstall -y 2>&1 | tee -a "$LOG_FILE"
        rm -rf "$BASE_DIR/.cargo" "$BASE_DIR/.rustup" 2>&1 | tee -a "$LOG_FILE"
    fi

    echo "Cleaning PATH in .bashrc..." | tee -a "$LOG_FILE"
    if [ -f "$BASE_DIR/.bashrc" ]; then
        sed -i '/\.soundness\/bin/d' "$BASE_DIR/.bashrc"
    fi

    echo "Uninstallation completed. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
}

if [ $# -eq 0 ]; then
    echo "Soundness Manager:"
    echo "1. Install Soundness"
    echo "2. Uninstall Soundness"
    read -p "Choose an option (1 or 2): " choice
else
    choice="$1"
fi

case "$choice" in
    1|"install") install_soundness ;;
    2|"uninstall") uninstall_soundness ;;
    *) echo "Invalid option. Use 1 (install) or 2 (uninstall)." ;;
esac
