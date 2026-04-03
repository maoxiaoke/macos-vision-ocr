#!/bin/bash
set -euo pipefail

REPO="maoxiaoke/macos-vision-ocr"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="ocr"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[info]${NC} $1"; }
warn() { echo -e "${YELLOW}[warn]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; exit 1; }

# Check macOS
if [ "$(uname -s)" != "Darwin" ]; then
    error "This tool only supports macOS."
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    arm64)  ARCH_SUFFIX="arm64" ;;
    x86_64) ARCH_SUFFIX="x86_64" ;;
    *)      error "Unsupported architecture: $ARCH" ;;
esac

info "Detected architecture: $ARCH_SUFFIX"

# Get latest release version
info "Fetching latest release..."
LATEST_VERSION=$(curl -sL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    error "Failed to fetch latest release. Check your network connection."
fi

info "Latest version: $LATEST_VERSION"

# Download
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST_VERSION}/ocr-macos-${ARCH_SUFFIX}-${LATEST_VERSION}.zip"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

info "Downloading $DOWNLOAD_URL ..."
HTTP_CODE=$(curl -sL -w "%{http_code}" -o "$TEMP_DIR/ocr.zip" "$DOWNLOAD_URL")

if [ "$HTTP_CODE" != "200" ]; then
    error "Download failed (HTTP $HTTP_CODE). URL: $DOWNLOAD_URL"
fi

# Extract
info "Extracting..."
unzip -q "$TEMP_DIR/ocr.zip" -d "$TEMP_DIR"

# Install
BINARY_FILE="$TEMP_DIR/ocr-${ARCH_SUFFIX}"
if [ ! -f "$BINARY_FILE" ]; then
    error "Binary not found in archive."
fi

chmod +x "$BINARY_FILE"

info "Installing to $INSTALL_DIR/$BINARY_NAME ..."
if [ -w "$INSTALL_DIR" ]; then
    mv "$BINARY_FILE" "$INSTALL_DIR/$BINARY_NAME"
else
    sudo mv "$BINARY_FILE" "$INSTALL_DIR/$BINARY_NAME"
fi

info "Successfully installed! Run 'ocr --help' to get started."
