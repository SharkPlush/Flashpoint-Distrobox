#!/bin/bash
check_depedencies() {
IN="$(basename "$(command -v curl || command -v wget)")" || { echo "An installation of curl or wget need to be present! Please look up how to install one of these for your distribution."; exit 1; }

command -v podman > /dev/null 2>&1 || command -v docker > /dev/null 2>&1 || { echo "An installation of Podman or Docker need to be present! Please look up how to install one of these for your distribution."; exit 1; }

command -v distrobox > /dev/null 2>&1 || { echo "An installation of Distrobox need to be present! Please look up how to install it your distribution."; exit 1; }

install_flashpoint
}

install_flashpoint() {
echo "Installing the Flashpoint archive file.."

case "$IN" in
  curl) "$IN" -sL -o $HOME/.cache/fp14.0.3_lin_20251201.7z "https://download.flashpointarchive.org/upload/fp14.0.3_lin_20251201.7z" ;;
  wget) "$IN" -qO $HOME/.cache/fp14.0.3_lin_20251201.7z "https://download.flashpointarchive.org/upload/fp14.0.3_lin_20251201.7z" ;;
esac

mkdir -p $HOME/.flashpoint 

echo "Flashpoint archive file installed.."

setup_container
}

setup_container() {
echo "Distrobox will install a Fedora 40 image and all the dependencies Flashpoint needs inside the container."

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

rm -r $HOME/.cache/fp14.0.3_lin_20251201.7z

echo "The container is installed and set up."

setup_flashpoint
}

setup_flashpoint() {
echo "Configuring Flashpoint.."

rm -r $HOME/.flashpoint/Libraries

rm -r $HOME/.flashpoint/FPSoftware/Wine

mkdir -p $HOME/.local/bin

cat > $HOME/.local/bin/flashpointwrapper.sh <<EOF
#!/bin/bash
cleanup() {
echo Y | distrobox stop Flashpoint
}
trap cleanup EXIT
distrobox enter Flashpoint -- bash -lc '/usr/bin/env -S WINEPREFIX="$HOME/.flashpoint/FPSoftware/Wine" $HOME/.flashpoint/Launcher/flashpoint-launcher --js-flags=--lite_mode --ozone-platform-hint=auto'
EOF

chmod +x $HOME/.local/bin/flashpointwrapper.sh

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

$HOME/.flashpoint/./start-flashpoint.sh & pid=$!

kill -INT $pid

echo "Flashpoint has been installed."

exit 0
}

echo "This installation might take a while, if you think something froze it likely didn't just be patient!"
check_depedencies
