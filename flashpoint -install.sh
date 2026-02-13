#!/bin/bash

check_depedencies() {
local Yn

if ! curl --version > /dev/null 2>&1; then
  if ! wget --version > /dev/null 2>&1; then
    echo "curl and wget are not installed, please look up how to install one of these for your distribution or this install script can't function."
    exit 0
  else
    IN=wget
  fi
else
  IN=curl
fi  
  
if ! podman --version > /dev/null 2>&1; then
  if ! docker --version > /dev/null 2>&1; then
    echo "Podman and Docker are not installed, please look up how to install one of these for your distribution or Distrobox can't function."
    exit 0
  fi
fi
  
if ! distrobox version > /dev/null 2>&1; then
  echo "Distrobox not installed, would you like to install it?"
  read -rp "Install distrobox? [Y/n] " Yn
  if [[ "$Yn" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
    if [[ "$IN" == "curl" ]]; then
      curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
      install_flashpoint
    elif [[ "$IN" == "wget" ]]; then
      wget -qO- https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
      install_flashpoint
    fi  
  elif [[ "$Yn" =~ ^([Nn]|[Nn][Oo])$ ]]; then
    echo "This installer *NEEDS* Distrobox to work."
    exit 0
  else
    echo "Unknown option, exiting.."
    exit 0
  fi
else
  install_flashpoint
fi
}

install_flashpoint() {
echo "Installing the Flashpoint archive file.."
if [[ "$IN" == "curl" ]]; then
  curl -sL -o /home/$USER/.cache/fp14.0.3_lin_20251201.7z "https://download.flashpointarchive.org/upload/fp14.0.3_lin_20251201.7z"
elif [[ "$IN" == "wget" ]]; then
  wget -q -O /home/$USER/.cache/fp14.0.3_lin_20251201.7z "https://download.flashpointarchive.org/upload/fp14.0.3_lin_20251201.7z"
fi
mkdir -p /home/$USER/.flashpoint
echo "Flashpoint archive file installed.."
setup_container
}

setup_container() {
echo "Distrobox will install a Fedora 40 image and all the dependencies Flashpoint needs inside the container."
echo Y | distrobox create --image fedora:40 --name Flashpoint > /dev/null 2>&1
distrobox enter Flashpoint -- bash -c "sudo dnf install xorg-x11-server-Xwayland gtk3 nss pipewire-pulseaudio php p7zip wine libXcomposite.i686 pulseaudio-libs.i686 gtk2 libXt -y && 7za x /home/$USER/.cache/fp14.0.3_lin_20251201.7z -o/home/$USER/.flashpoint && exit" > /dev/null 2>&1
echo Y | distrobox stop Flashpoint > /dev/null 2>&1
rm -r /home/$USER/.cache/fp14.0.3_lin_20251201.7z
echo "The container is installed and set up."
setup_flashpoint
}

setup_flashpoint() {
echo "Configuring Flashpoint.."
rm -r /home/$USER/.flashpoint/Libraries
rm -r /home/$USER/.flashpoint/FPSoftware/Wine
mkdir -p /home/$USER/.local/bin

cat > /home/$USER/.local/bin/flashpointwrapper.sh <<EOF
#!/bin/bash
cleanup() {
echo Y | distrobox stop Flashpoint
}
trap cleanup EXIT
distrobox enter Flashpoint -- bash -lc '/usr/bin/env -S WINEPREFIX="/home/$USER/.flashpoint/FPSoftware/Wine" /home/$USER/.flashpoint/Launcher/flashpoint-launcher --js-flags=--lite_mode --ozone-platform-hint=auto'
EOF

chmod +x /home/$USER/.local/bin/flashpointwrapper.sh

cat > /home/$USER/.local/share/applications/flashpoint-archive.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Flashpoint Archive
Comment=An archive for games and animations from the web.
Icon=/home/$USER/.flashpoint/Launcher/icon.svg
StartupWMClass=flashpoint-launcher
Exec=/home/$USER/.local/bin/flashpointwrapper.sh
Path=/home/$USER/.flashpoint/Launcher
Terminal=false
Categories=Archiving;Game;
SingleMainWindow=true
EOF

/home/$USER/.flashpoint/./start-flashpoint.sh & pid=$!
kill -INT $pid
echo "Flashpoint has been installed."
exit 0
}
echo "This installation might take a while, if you think something froze it likely didn't just be patient!"
check_depedencies#!/bin/bash

check_distrobox() {
local Yn
if ! distrobox version; then
  echo "Distrobox not installed, would you like to install it?"
  read -rp "Install distrobox? [Y/n] " Yn
  if [[ "$Yn" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
    curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
    install_flashpoint
  elif [[ "$Yn" =~ ^([Nn]|[Nn][Oo])$ ]]; then
    echo "This installer *NEEDS* Distrobox to work."
    exit 0
  else
    echo "Unknown option, exiting.."
    exit 0
  fi
else
  install_flashpoint
fi
}

install_flashpoint() {
curl -L -o /home/$USER/.cache/fp14.0.3_lin_20251201.7z "https://download.flashpointarchive.org/upload/fp14.0.3_lin_20251201.7z"
mkdir -p /home/$USER/.flashpoint
setup_container
}

setup_container() {
echo "Distrobox will install a Fedora 40 image and all the dependencies Flashpoint needs inside the container."
distrobox create --image fedora:40 --name Flashpoint
distrobox enter Flashpoint -- bash -c "sudo dnf install xorg-x11-server-Xwayland gtk3 nss pipewire-pulseaudio php p7zip wine libXcomposite.i686 pulseaudio-libs.i686 gtk2 libXt -y && 7za x /home/$USER/.cache/fp14.0.3_lin_20251201.7z -o/home/$USER/.flashpoint && exit"
echo Y | distrobox stop Flashpoint
rm -r /home/$USER/.cache/fp14.0.3_lin_20251201.7z
setup_flashpoint
}

setup_flashpoint() {
rm -r /home/$USER/.flashpoint/Libraries
rm -r /home/$USER/.flashpoint/FPSoftware/Wine
mkdir -p /home/$USER/.local/bin

cat > /home/$USER/.local/bin/flashpointwrapper.sh <<EOF
#!/bin/bash
cleanup() {
echo Y | distrobox stop Flashpoint
}
trap cleanup EXIT
distrobox enter Flashpoint -- bash -lc '/usr/bin/env -S WINEPREFIX="/home/$USER/.flashpoint/FPSoftware/Wine" /home/$USER/.flashpoint/Launcher/flashpoint-launcher --js-flags=--lite_mode --ozone-platform-hint=auto'
EOF

chmod +x /home/$USER/.local/bin/flashpointwrapper.sh

cat > /home/$USER/.local/share/applications/flashpoint-archive.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Flashpoint Archive
Comment=An archive for games and animations from the web.
Icon=/home/$USER/.flashpoint/Launcher/icon.svg
StartupWMClass=flashpoint-launcher
Exec=/home/$USER/.local/bin/flashpointwrapper.sh
Path=/home/$USER/.flashpoint/Launcher
Terminal=false
Categories=Archiving;Game;
SingleMainWindow=true
EOF

/home/$USER/.flashpoint/./start-flashpoint.sh & pid=$!
kill -INT $pid
echo "Flashpoint has been installed."
exit 0
}

check_distrobox
