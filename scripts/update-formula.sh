#!/bin/bash
set -euo pipefail

# Usage: ./scripts/update-formula.sh <version>
# Example: ./scripts/update-formula.sh 1.0.0
#
# This script updates the Homebrew formula with the correct version and SHA256 checksums.
# Run this AFTER creating a GitHub release.

REPO="maoxiaoke/macos-vision-ocr"
FORMULA="HomebrewFormula/ocr.rb"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

VERSION="$1"
TAG="v${VERSION}"

echo "Updating formula for version ${VERSION}..."

# Download release assets and compute SHA256
ARM64_URL="https://github.com/${REPO}/releases/download/${TAG}/ocr-macos-arm64-${TAG}.zip"
X86_64_URL="https://github.com/${REPO}/releases/download/${TAG}/ocr-macos-x86_64-${TAG}.zip"

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Downloading arm64 binary..."
curl -sL -o "$TEMP_DIR/arm64.zip" "$ARM64_URL"
SHA256_ARM64=$(shasum -a 256 "$TEMP_DIR/arm64.zip" | awk '{print $1}')

echo "Downloading x86_64 binary..."
curl -sL -o "$TEMP_DIR/x86_64.zip" "$X86_64_URL"
SHA256_X86_64=$(shasum -a 256 "$TEMP_DIR/x86_64.zip" | awk '{print $1}')

echo "ARM64  SHA256: $SHA256_ARM64"
echo "X86_64 SHA256: $SHA256_X86_64"

# Update formula
sed -i '' "s/VERSION/${VERSION}/g" "$FORMULA"
sed -i '' "s/SHA256_ARM64/${SHA256_ARM64}/" "$FORMULA"
sed -i '' "s/SHA256_X86_64/${SHA256_X86_64}/" "$FORMULA"

echo "Formula updated successfully!"
echo ""
echo "Next steps:"
echo "  1. Copy HomebrewFormula/ocr.rb to your homebrew-tap repo (maoxiaoke/homebrew-tap)"
echo "  2. Commit and push the tap repo"
echo "  3. Users can then: brew install maoxiaoke/tap/ocr"
