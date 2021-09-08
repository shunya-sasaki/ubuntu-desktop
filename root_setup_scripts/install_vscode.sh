#!/bin/sh
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

apt install -y apt-transport-https
apt update -y && apt install -y code

sed -e 's/Exec=\/usr\/share\/code\/code --unity-launch %F/Exec=\/usr\/share\/code\/code --unity-launch --no-sandbox %F/g' \
    -i /usr/share/applications/code.desktop