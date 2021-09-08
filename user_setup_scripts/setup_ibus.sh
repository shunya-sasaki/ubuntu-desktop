#!/bin/sh
# ibus.conf
echo "[general]" > ~/.setup/ibus.conf && \
echo "preload-engines=['mozc-jp']" >> ~/.setup/ibus.conf && \
echo "version='1.5.22'" >> ~/.setup/ibus.conf
# run_ibus.sh
echo "#!/bin/sh" > ~/.setup/run_ibus.sh && \
echo "dconf load /desktop/ibus/ < ~/.setup/ibus.conf" >> ~/.setup/run_ibus.sh && \
echo "ibus-daemon -rdx" >> ~/.setup/run_ibus.sh
# autostart
mkdir -p /home/${USER_NAME}/.config/autostart && \
echo '[Desktop Entry]' > ~/.config/autostart/ibus.desktop && \
echo 'Exec=bash ~/.setup/run_ibus.sh' >> ~/.config/autostart/ibus.desktop && \
echo 'Name=ibus' >> ~/.config/autostart/ibus.desktop && \
echo 'OnlyShowIn=LXQt;' >> ~/.config/autostart/ibus.desktop && \
echo 'Type=Application' >> ~/.config/autostart/ibus.desktop && \
echo 'Version=1.0' >> ~/.config/autostart/ibus.desktop & \
# ibus on xrdp
echo 'export GTK_IM_MODULE=ibus' >> ~/.bashrc && \
echo 'export XMODIFIERS=@im=ibus' >> ~/.bashrc && \
echo 'export QT_IM_MODULE=ibus' >> ~/.bashrc && \
# im-config
im-config -n ibus