Use [Flashpoint](https://flashpointarchive.org/) inside a Distrobox container.

This tool is a management tool that can install, uninstall and update flashpoint. Ontop of some other things.

This is mostly meant for immutable Linux distributions, but you can 100% run this on anything if you have Distrobox.

You need Distrobox for this to work.

Root privilages are NOT (and not recommended) needed and everything installed will be limited to your user home folder.

This installer configures the Distrobox container to automatically shutdown after you exit Flashpoint without any background services! So it basically behaves like a normal app and won't leave any leftover processes.

I don't own a steamdeck or an NVIDIA GPU so I don't know how this will work on those devices.

To install download the bash script and make it executable. I recommend tossing it into $HOME/.local/bin/ also.

Why this exists? Wines WOW64 (which flashpoint started shipping) update messed up half the games I played and I couldn't play them. This installer uses a Fedora 40 image for Distrobox and installs a Pre WOW64 Wine so the game work properly.

TODO:
- Add a progress bar.
- General cleanups and whatever.
