# 🏗️ archy-factory

My own automated Arch Linux install factory, to spin up VMs and bootstrap `archinstall` with a few bash scripts.

## Usage

### Download ISO

First download the latest Arch Linux ISO file:

```bash
bash ./scripts/dl-arch-iso.sh
```

### Create the Virtual Machine

Run the `create-vm.sh` and pass the ISO path as first argument:

```bash
bash ./scripts/create-vm.sh ./isos/archlinux-x86_64.iso
```

At this point, the VM should have been created and started.

### Connect to the VM

Attach to the VM using Virtual Machine Manager or `virt-viewer`:

```bash
virt-viewer --connect qemu:///system archlinux
```

Then go through the boot loader to go into installing Arch.

### Fetch `archinstall.sh`

> [!TIP]
> Skip this if you don't care about my dotfiles.

Once you are `arch-chroot`*-ed*, fetch my custom `archinstall.sh` script:

```bash
# Run the custom archinstall.sh
curl -sL df.lazyfreax.dev/archinstall.sh | bash
# or
bash <(curl -sL df.lazyfreax.dev/archinstall.sh)
```
