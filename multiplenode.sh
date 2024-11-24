#!/bin/bash

if [ ! -f "loader.sh" ]; then
    echo "Displaying HCA logo..."
    wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh
    chmod +x loader.sh
    ./loader.sh
else
    echo "HCA loader.sh is already present. Skipping the download."
fi

curl -s https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/logo.sh | bash
sleep 2

echo "Starting system update..."
sudo apt update && sudo apt upgrade -y

echo "Checking system architecture..."
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    CLIENT_URL="https://cdn.app.multiple.cc/client/linux/x64/multipleforlinux.tar"
elif [[ "$ARCH" == "aarch64" ]]; then
    CLIENT_URL="https://cdn.app.multiple.cc/client/linux/arm64/multipleforlinux.tar"
else
    echo "Unsupported system architecture: $ARCH"
    exit 1
fi

echo "Downloading the client from $CLIENT_URL..."
wget $CLIENT_URL -O multipleforlinux.tar

echo "Extracting files..."
tar -xvf multipleforlinux.tar

echo "Granting permissions..."
chmod +x ./multiple-cli
chmod +x ./multiple-node

echo "Adding directory to system PATH..."
echo "PATH=\$PATH:$(pwd)" >> ~/.bash_profile
source ~/.bash_profile

echo "Setting permissions..."
chmod -R 777 $(pwd)

echo "Launching multiple-node..."
nohup ./multiple-node > output.log 2>&1 &

echo "Please input your Account ID and PIN to bind your account:"
read -p "Account ID: " IDENTIFIER
read -p "PIN: " PIN

echo "Binding account with ID: $IDENTIFIER and PIN: $PIN..."
multiple-cli bind --bandwidth-download 100 --identifier $IDENTIFIER --pin $PIN --storage 200 --bandwidth-upload 100

echo "Installation completed successfully!"
echo "Subscribe: https://t.me/HappyCuanAirdrop"
