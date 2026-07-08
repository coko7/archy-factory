# 🏗️ archy-factory

Automated Arch Linux install factory — spin up VMs and bootstrap unattended archinstall setups via a one-line curl script.

steps:

```bash
bash ./scripts/dl-arch-iso.sh
bash ./scripts/create-vm.sh ./isos/archlinux-x86_64.iso
# go to vm and have some fun
# then in VM:
curl -sL archy.coko7.fr | bash
# or
bash <(curl -sL archy.coko7.fr)
```
