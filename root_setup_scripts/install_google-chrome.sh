#!/bin/sh
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
apt update -y && apt install -y google-chrome-stable
sed -e 's/Exec=\/usr\/bin\/google-chrome-stable %U/Exec=\/usr\/bin\/google-chrome-stable --no-sandbox %U/g' \
    -i /usr/share/applications/google-chrome.desktop

# wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# apt install -y ./google-chrome-stable_current_amd64.deb && rm -rf ./google-chrome-stable_current_amd64.deb
