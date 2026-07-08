# Saving and Retrieving archinstall Configs from a VM

Complete walkthrough: run `archinstall` in a VM, save the configuration files
into the installed system, and download them to your host machine using
Python's built-in HTTP server. No SSH or scp required.

---

## 1. Run archinstall and configure your system

Boot the Arch ISO in your VM and run:

```
archinstall
```

Go through the menu and set up disks, profile, users, etc. as usual.

## 2. Save the configuration

In the archinstall main menu, choose **Save configuration**.

- When prompted for a destination, enter a **directory**, not a file name —
  archinstall creates `user_configuration.json` (and `user_credentials.json`
  if you choose to save credentials) itself.
- **Timing matters:** the target system's mountpoint `/mnt/archinstall/` only
  exists once the installation has actually run. So:
  - **If you're saving before starting the install** (the usual case): save to
    `/root`. You'll copy the files into the installed system in step 4.
  - **If archinstall lets you save after the install completed** (or you
    re-enter the save menu later): you can save directly to
    `/mnt/archinstall/root/` and skip step 4.

> On older archinstall versions the install target is mounted at `/mnt`
> instead of `/mnt/archinstall`. Check with `ls /mnt` — the one containing
> `etc`, `usr`, `home` is your installed system.

## 3. Start the installation

Select **Install** and let it finish. When asked if you want to **chroot into
the new installation for post-installation configuration**, do your
post-install work if needed, then **exit the chroot** (`exit` or Ctrl+D) so
you're back in the live ISO shell.

Remember: inside the chroot, `/root` is the *installed system's* root home.
The config you saved in step 2 lives in the *live ISO's* `/root`, which is
only visible outside the chroot.

## 4. Copy the config files into the installed system

Still in the live ISO shell (not chrooted), copy the saved files onto the
installed system's disk so they survive the reboot (the live `/root` is
RAM-only and disappears on shutdown):

```
cp /root/user_configuration.json /mnt/archinstall/root/
cp /root/user_credentials.json  /mnt/archinstall/root/   # if it exists
```

Verify:

```
ls /mnt/archinstall/root/
```

## 5. Reboot into the installed system

```
reboot
```

(Remove/detach the ISO from the VM if it boots back into the installer.)

Log in as your user (or root) in the new system.

## 6. Serve the files with Python's HTTP server

In the VM, find the files and note your IP address:

```
sudo cp /root/user_*.json ~/        # make them readable by your user
ip a                                # note the VM's IP, e.g. 192.168.122.45
cd ~
python -m http.server 8000
```

Leave this running. It serves the current directory on port 8000.

> **Networking note:** with libvirt/virt-manager default NAT, VirtualBox
> bridged/host-only, or VMware NAT, the host can reach the VM IP directly.
> With plain QEMU *user-mode* networking the host cannot reach the VM —
> add a port forward when launching QEMU, e.g.
> `-nic user,hostfwd=tcp::8000-:8000`, then use `localhost:8000` on the host.

## 7. Download the files on the host

Open `http://VM_IP:8000` in a browser and click the files, or use curl:

```
curl -O http://VM_IP:8000/user_configuration.json
curl -O http://VM_IP:8000/user_credentials.json
```

## 8. Stop the server

Back in the VM, press **Ctrl+C** to stop the HTTP server. Don't leave it
running — it serves files to anyone on the network with no authentication,
and `user_credentials.json` contains password hashes/secrets.

Consider deleting the copies in your home directory afterward:

```
rm ~/user_credentials.json
```

---

## Reusing the configuration later

To replay the install on another machine or VM, boot the Arch ISO, get the
files onto it (e.g. `curl` them from wherever you host them), then:

```
archinstall --config user_configuration.json --creds user_credentials.json
```

Review the menu, adjust anything host-specific (disks!), and install.

---

## Quick troubleshooting

| Problem | Fix |
| --- | --- |
| "Invalid directory" when saving | You entered a file name or a directory that doesn't exist. Enter an existing directory like `/root`. |
| Config not visible inside chroot | Exit the chroot — the file is in the live ISO's `/root`, not the installed system's. |
| `/var/log/archinstall/` missing | Not all versions write configs there; rely on the manual copy in step 4. |
| Host can't reach `VM_IP:8000` | QEMU user-mode networking needs `hostfwd` port forwarding, or switch the VM to libvirt NAT/bridged networking. |
| Files not listed by the HTTP server | The server serves the directory it was started in — `cd` to where the JSON files are first. |
