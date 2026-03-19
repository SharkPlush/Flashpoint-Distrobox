Management tool for Flashpoint + Distrobox

This is a CLI application meant for using Flashpoint inside of a Distrobox container.

To install:

Make sure Distrobox is installed with `command -v distrobox` if it's not installed you can install it [here](https://distrobox.it/#installation).

**Do NOT use sudo for any of these commands.**

1. Download the [flashpoint-manager](https://github.com/SharkPlush/Flashpoint-Distrobox/blob/main/flashpoint-manager) file in this repository.
2. Make the file executable with `chmod +x path/to/flashpoint-manager` OR make it executable from your file manager.
3. Move the file to "~/.local/bin/" is this file doesn't exist then run `mkdir -p ~/.local/bin/` OR create the file inside your file manager.
4. Open the terminal and run `flashpoint-manager --install-flashpoint` 

Features:
  - Auto Installation. (You must provide the Flashpoint .7z file)
  - Easier updates. (You must provide the Flashpoint .z7 file)
  - Some data preservation between updates. (Still in testing)
  - Distrobox container stops after Flashpoint is closed.
  - Isolation to "$HOME/.flashpoint" (Except the wrapper and .desktop file)

## Warning
  - I consider this to be untested beta software so stuff might go wrong.
  - This project is **NOT** associated with the Flashpoint project.

Why this exists?
1. After Flashpoint started using WOW64 for Wine most of the games I play became unplayable.
2. Flashpoint updates on Linux aren't simple if you want to preserve you game data.
3. I disliked the extra files Wine generated inside "~/.local/share/applications"
4. This just feels like a more stable way to use Flashpoint than the official Linux versions approach.

How this works?

For normal people:
1. Install.
2. Open Flashpoint.
3. Profit.

For nerds:
1. A Distrobox container is created with it's own internal $HOME
2. Flashpoints dependencies are installed inside the container.
3. A wrapper is created that starts the container then opens Flashpoint inside of it. This allows for stuff like Wine to work.
4. A .desktop file is created for the wrapper.

The internal home is stored inside of your user home directory "~/.flashpoint" only two files will be outside of this directory (the wrapper and .desktop file) everything else should be contained to the Distrobox internal home.

TODO:
  - NVIDIA support. (Need help don't have a NVIDIA GPU)
  - Steamdeck support. (Need help don't have a Steamdeck also already might be supported I don't know it works to test though)
  - Discord rich presence if it doesn't work already. (Unlikely I'll do this if it doesn't work)
  - Give the user a choice to user to use an image they like instead of the fedora:40 one.
  - Create backup feature and a restore backup feature.
