#!/bin/sh
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
/usr/bin/supervisord
