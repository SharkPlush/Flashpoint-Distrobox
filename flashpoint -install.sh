#!/bin/bash
check_depedencies() {
IN="$(basename "$(command -v curl || command -v wget)")" || { echo "An installation of curl or wget need to be present! Please look up how to install one of these for your distribution."; exit 1; }
command -v distrobox > /dev/null 2>&1 || { echo "An installation of Distrobox need to be present! Please look up how to install it your distribution."; echo "https://distrobox.it/#installation"; exit 1; }
install_flashpoint
}

install_flashpoint() {
echo "Installing Flashpoint.."
if [ -d $HOME/.flashpoint ]; then
  if [ -d $HOME/.flashpoint/Launcher/flashpoint-launcher ]; then
    echo "Flashpoint is already installed! Exiting.."; exit 0
  else
    # This should only trigger is the user has a .flashpoint directory that wasn't meant for Flashpoint i.e they are keeping other files there!
    echo "A Flashpoint directory already exists '$HOME/.flashpoint' would you like to delete everything in this directory?"
    read -rp "[Y/n] " Yn
    if [[ "$Yn" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
      rm -rf $HOME/.flashpoint/.[!.]*
    elif [[ "$Yn" =~ ^([Nn]|[Nn][Oo])$ ]]; then
      echo "'$HOME/.flashpoint' is needed for installing Flashpoint, exiting.."; exit 1
    else
      echo "Unknown option, exiting.."; exit 1
    fi  
  fi  
else
  mkdir -p $HOME/.flashpoint 
fi
case "$IN" in
  curl) curl -sL -o $HOME/.cache/fp14.0.3_lin_20251201.7z "https://download.flashpointarchive.org/upload/fp14.0.3_lin_20251201.7z" ;;
  wget) wget -qO $HOME/.cache/fp14.0.3_lin_20251201.7z "https://download.flashpointarchive.org/upload/fp14.0.3_lin_20251201.7z" ;;
esac
setup_container
}

setup_container() {
echo "Distrobox will install a Fedora 40 image and all the dependencies Flashpoint needs inside the container."

# The idea behind this check is if a user already has a Distrobox container named "Flashpoint" being used for another reason besides Flashpoint though this def needs improvements
if distrobox list | grep -qw "Flashpoint"; then
  echo "A Distrobox container named 'Flashpoint' already exists, would you like to delete and reinstall it?"
  read -rp "[Y/n] " Yn
  if [[ "$Yn" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
    echo Y | distrobox rm Flashpoint > /dev/null 2>&1
  elif [[ "$Yn" =~ ^([Nn]|[Nn][Oo])$ ]]; then
    echo "The script requires a fresh Distrobox container named 'Flashpoint', exiting.."; exit 1
  fi  
fi
echo Y | distrobox create --no-entry --image fedora:40 --name Flashpoint > /dev/null 2>&1
distrobox enter Flashpoint -- bash -c "sudo dnf install xorg-x11-server-Xwayland \
                                                        gtk3 \
                                                        nss \
                                                        pipewire-pulseaudio \
                                                        php \
                                                        p7zip \
                                                        wine \
                                                        libXcomposite.i686 \
                                                        pulseaudio-libs.i686 \
                                                        gtk2 \
                                                        libXt -y \
                                                        && 7za x $HOME/.cache/fp14.0.3_lin_20251201.7z -o$HOME/.flashpoint \
                                                        && exit" > /dev/null 2>&1
echo Y | distrobox stop Flashpoint > /dev/null 2>&1
rm $HOME/.cache/fp14.0.3_lin_20251201.7z
echo "The container is installed and set up."
setup_flashpoint
}

setup_flashpoint() {
echo "Configuring Flashpoint.."
rm -r $HOME/.flashpoint/Libraries
rm -r $HOME/.flashpoint/FPSoftware/Wine
mkdir -p $HOME/.local/bin
if [ -d $HOME/.local/bin/flashpointwrapper.sh ]; then
  rm $HOME/.local/bin/flashpointwrapper.sh
fi 
cat > $HOME/.local/bin/flashpointwrapper.sh <<EOF
#!/bin/bash
cleanup() {
echo Y | distrobox stop Flashpoint
}
trap cleanup EXIT
distrobox enter Flashpoint -- bash -lc '/usr/bin/env -S WINEPREFIX="$HOME/.flashpoint/FPSoftware/Wine" $HOME/.flashpoint/Launcher/flashpoint-launcher --js-flags=--lite_mode --ozone-platform-hint=auto'
EOF
chmod +x $HOME/.local/bin/flashpointwrapper.sh
if [ -d $HOME/.local/share/applications/flashpoint-archive.desktop ]; then
  rm $HOME/.local/share/applications/flashpoint-archive.desktop
fi 
cat > $HOME/.local/share/applications/flashpoint-archive.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Flashpoint Archive
Comment=An archive for games and animations from the web.
Icon=$HOME/.flashpoint/Launcher/icon.svg
StartupWMClass=flashpoint-launcher
Exec=$HOME/.local/bin/flashpointwrapper.sh
Path=$HOME/.flashpoint/Launcher
Terminal=false
Categories=Archiving;Game;
SingleMainWindow=true
EOF

# Flashpoint needs to run at least once for it to work like normal with this setup for some reason.?
$HOME/.flashpoint/./start-flashpoint.sh & pid=$!
kill -INT $pid
echo "Flashpoint has been installed."
exit 0
}
echo "This installation might take a while, if you think something froze it likely didn't just be patient!"
check_depedencies
