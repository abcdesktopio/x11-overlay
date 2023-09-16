#!/bin/bash
X11SOCKET=/tmp/.X11-unix/X0
echo "waiting for socket $X11SOCKET"
while [ ! -S $X11SOCKET ]; do
	echo -n '.'
	sleep  0.1
done
echo "$ABCDESKTOP_USERNAME\n$ABCDESKTOP_PROVIDERNAME\n$ABCDESKTOP_USERID" > /data/overlay.txt
/usr/local/bin/overlay /data/overlay.txt -f Arial -d 0 -o CENTER -s 100 -t 4 -o CENTER
