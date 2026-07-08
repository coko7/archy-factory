#!/usr/bin/env bash
#
# download-arch-iso.sh
# Downloads the latest Arch Linux ISO (with checksum + signature verification)
#
# Usage: ./download-arch-iso.sh [target-directory]
#        Default target directory: ~/isos

set -euo pipefail

# curl -fsSL is `curl --fail --silent --show-error --location`

MIRROR="https://geo.mirror.pkgbuild.com/iso/latest"
TARGET_DIR="${1:-./isos}"
ISO_NAME="archlinux-x86_64.iso"

mkdir --parents "$TARGET_DIR"
cd "$TARGET_DIR"

echo ">>> Fetching checksum file..."
curl -fsSL -o sha256sums.txt "$MIRROR/sha256sums.txt"

# Extract the expected checksum for the rolling "latest" ISO
EXPECTED_SUM=$(awk -v iso="$ISO_NAME" '$2 == iso {print $1}' sha256sums.txt)
if [[ -z "$EXPECTED_SUM" ]]; then
  echo "ERROR: Could not find checksum for $ISO_NAME" >&2
  exit 1
fi

# Skip download if we already have a matching ISO
if [[ -f "$ISO_NAME" ]]; then
  echo ">>> Existing ISO found, verifying..."
  if echo "$EXPECTED_SUM  $ISO_NAME" | sha256sum -c --quiet 2>/dev/null; then
    echo ">>> $TARGET_DIR/$ISO_NAME is already the latest version. Nothing to do."
    exit 0
  else
    echo ">>> Existing ISO is outdated or corrupt, re-downloading."
    rm -f "$ISO_NAME"
  fi
fi

echo ">>> Downloading $ISO_NAME ..."
curl -fL --progress-bar -o "$ISO_NAME.part" "$MIRROR/$ISO_NAME"

echo ">>> Verifying checksum..."
if ! echo "$EXPECTED_SUM  $ISO_NAME.part" | sha256sum -c --quiet; then
  echo "ERROR: Checksum verification FAILED. Removing download." >&2
  rm -f "$ISO_NAME.part"
  exit 1
fi
mv "$ISO_NAME.part" "$ISO_NAME"

# Optional: verify PGP signature if gpg is available
if command -v gpg >/dev/null 2>&1; then
  echo ">>> Verifying PGP signature..."
  curl -fsSL -o "$ISO_NAME.sig" "$MIRROR/$ISO_NAME.sig"

  # Fetch the Arch release signing key from WKD (official method)
  if gpg --auto-key-locate clear,wkd --verbose \
    --locate-external-key pierre@archlinux.org >/dev/null 2>&1 &&
    gpg --verify "$ISO_NAME.sig" "$ISO_NAME" 2>/dev/null; then
    echo ">>> PGP signature OK."
  else
    echo ">>> WARNING: PGP verification skipped/failed (checksum already verified)."
  fi
fi

echo ">>> Done: $TARGET_DIR/$ISO_NAME"
