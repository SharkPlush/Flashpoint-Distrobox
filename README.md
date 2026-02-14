Use [Flashpoint](https://flashpointarchive.org/) inside a Distrobox container.

This is mostly meant for immutable Linux distributions, but you can 100% run this on anything if you have Distrobox.

You need curl or wget for this script to work and Distrobox. (duh) Most distributions have curl and wget already so most of you don't have to worry about that.

This installer configures the Distrobox container to automatically shutdown after you exit Flashpoint without any background services! So it basically behaves like a normal app and won't leave any leftover processes.

I don't own a steamdeck or an NVIDIA GPU so I don't know how this will work on those devices.

INSTALL:
```
curl -s https://raw.githubusercontent.com/SharkPlush/Flashpoint-Distrobox/refs/heads/main/flashpoint%20-install.sh
```
OR
```
wget -qO- https://raw.githubusercontent.com/SharkPlush/Flashpoint-Distrobox/refs/heads/main/flashpoint%20-install.sh
```
Or you can download the .sh file and run it manually.

TODO:
- Maybe add Toolbx support.
- Add an updater.
- Have the script automatically pull the latest Flashpoint .zip
- Create uninstaller.
- Add a progress bar.
- General cleanups and whatever.
