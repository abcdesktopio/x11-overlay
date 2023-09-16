#!/bin/bash
X11SOCKET=/tmp/.X11-unix/X0
echo "waiting for socket $X11SOCKET"
while [ ! -S $X11SOCKET ]; do
	echo -n '.'
	sleep  0.1
done
echo "$ABCDESKTOP_USERNAME\n$ABCDESKTOP_PROVIDERNAME\n$ABCDESKTOP_USERID" > /data/overlay.txt

# .Xauthority
if [ ! -f ~/.Xauthority ]; then
	log "~/.Xauthority does not exist"
	ls -la ~ >> $STDOUT_LOGFILE
	# create a MIT-MAGIC-COOKIE-1 entry in .Xauthority
	if [ ! -z "$XAUTH_KEY" ]; then
        	log "xauth add $DISPLAY MIT-MAGIC-COOKIE-1 $XAUTH_KEY"
        	xauth add $DISPLAY MIT-MAGIC-COOKIE-1 $XAUTH_KEY >> $STDOUT_LOGFILE 2>&1
		log "xauth add done exitcode=$?"
	fi
else
	log "~/.Xauthority exists"
fi

/usr/local/bin/overlay /data/overlay.txt -f Arial -d 0 -o CENTER -s 100 -t 4 -o CENTER
