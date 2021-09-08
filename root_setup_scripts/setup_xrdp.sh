#!/bin/sh

sed -e 's/^new_cursors=true/new_cursors=false/g' -i /etc/xrdp/xrdp.ini && \
sed -e 's/test -x \/etc\/X11\/Xsession/# test -x \/etc\/X11\/Xsession/g' \
    -i  /etc/xrdp/startwm.sh && \
sed -e 's/exec \/bin\/sh \/etc\/x11\/Xsession/# exec \/bin\/sh \/etc\/x11\/Xsession/g' \
    -i /etc/xrdp/startwm.sh && \
echo '' >> /etc/xrdp/startwm.sh && \
echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /etc/xrdp/startwm.sh && \
echo 'exec lxqt-session' >> /etc/xrdp/startwm.sh && \
echo "test -x /etc/X11/Xsession && exec /etc/X11/Xsession" \
        >> /etc/xrdp/startwm.sh && \
echo "exec /bin/sh /etc/X11/Xsession" >> /etc/xrdp/startwm.sh && \
gpasswd -a xrdp ssl-cert
