#!/bin/bash
set -e

REPO="Bugzidna-Labs/bugz"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="bugz"

# Detect OS
OS="$(uname -s)"
if [ "$OS" = "Linux" ]; then
    ASSET_NAME="bugz-linux"
elif [ "$OS" = "Darwin" ]; then
    ASSET_NAME="bugz-macos"
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Get latest release tag
echo "Fetching latest release..."
LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ]; then
    echo "Error: Could not find latest release."
    exit 1
fi

DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/$ASSET_NAME"

echo "Downloading $BINARY_NAME ($LATEST_TAG) for $OS..."
curl -L "$DOWNLOAD_URL" -o "$BINARY_NAME"

chmod +x "$BINARY_NAME"

echo "Installing to $INSTALL_DIR (requires sudo)..."
sudo mv "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"

echo "Success! Run '$BINARY_NAME' to start."
