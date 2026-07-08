#!/usr/bin/env bash
#
# create-arch-vm.sh
# Creates a libvirt/KVM virtual machine from an Arch Linux ISO using virt-install.
#
# Usage: ./create-arch-vm.sh [iso-path]
#        Default ISO path: ~/isos/archlinux-x86_64.iso
#
# Tweak the variables below to taste.

set -euo pipefail

# ------------------------- Configuration -------------------------
VM_NAME="archlinux"
ISO_PATH="${1:-$HOME/isos/archlinux-x86_64.iso}"
VCPUS=4
RAM_MB=4096
DISK_SIZE_GB=40
DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"
NETWORK="default" # libvirt network name
LIBVIRT_URI="qemu:///system"
UEFI=true # set to false for legacy BIOS boot
# ------------------------------------------------------------------

# --- Sanity checks ---
if ! command -v virt-install >/dev/null 2>&1; then
  echo "ERROR: virt-install not found. Install it with: sudo pacman -S virt-install" >&2
  exit 1
fi

if [[ ! -f "$ISO_PATH" ]]; then
  echo "ERROR: ISO not found at $ISO_PATH" >&2
  echo "Run ./download-arch-iso.sh first, or pass the ISO path as an argument." >&2
  exit 1
fi

if virsh --connect "$LIBVIRT_URI" dominfo "$VM_NAME" >/dev/null 2>&1; then
  echo "ERROR: A VM named '$VM_NAME' already exists." >&2
  echo "Remove it with:  virsh --connect $LIBVIRT_URI undefine $VM_NAME --nvram --remove-all-storage" >&2
  exit 1
fi

# Make sure the default network is running. `net-list --name` prints only
# ACTIVE network names (raw, one per line) — locale-proof and flag-minimal.
if ! virsh --connect "$LIBVIRT_URI" net-list --name 2>/dev/null | grep -qx "$NETWORK"; then
  echo ">>> Starting libvirt network '$NETWORK'..."
  virsh --connect "$LIBVIRT_URI" net-start "$NETWORK"
fi

# --- Boot firmware ---
BOOT_ARGS=()
if [[ "$UEFI" == true ]]; then
  BOOT_ARGS=(--boot uefi)
fi

echo ">>> Creating VM '$VM_NAME' ($VCPUS vCPUs, ${RAM_MB}MB RAM, ${DISK_SIZE_GB}GB disk)"
echo ">>> ISO: $ISO_PATH"

virt-install \
  --connect "$LIBVIRT_URI" \
  --name "$VM_NAME" \
  --vcpus "$VCPUS" \
  --memory "$RAM_MB" \
  --cpu host-passthrough \
  --os-variant archlinux \
  --cdrom "$ISO_PATH" \
  "${BOOT_ARGS[@]}" \
  --disk "path=$DISK_PATH,size=$DISK_SIZE_GB,format=qcow2,bus=virtio,discard=unmap" \
  --network "network=$NETWORK,model=virtio" \
  --graphics spice \
  --video virtio \
  --channel spicevmc \
  --channel unix,target.type=virtio,target.name=org.qemu.guest_agent.0 \
  --memballoon virtio \
  --rng /dev/urandom \
  --noautoconsole

echo
echo ">>> VM '$VM_NAME' created and booting from the ISO."
echo ">>> Open it in virt-manager, or attach to the console with:"
echo "        virt-viewer --connect $LIBVIRT_URI $VM_NAME"
echo
echo ">>> After installing Arch inside the VM, it will boot from disk on the"
echo ">>> next restart automatically (--cdrom only boots the ISO once)."
