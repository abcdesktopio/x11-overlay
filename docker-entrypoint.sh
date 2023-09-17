#!/bin/bash

export DISPLAY=${DISPLAY:-':0'}
export USER=root
export HOME=/root
export LOGNAME=root
START_TIME=$(date +%s)

log() {
echo "$(date) $1"
}

X11SOCKET=/tmp/.X11-unix/X0
log "waiting for socket $X11SOCKET"
while [ ! -S $X11SOCKET ]; do
	echo -n '.'
	sleep  0.1
done

log "x11 is ready $X11SOCKET"


echo 'run inxi -Gxx'

until inxi -Gxx | grep compositor ; do 
	echo sleep 1
	sleep 1
done


echo "$ABCDESKTOP_USERNAME" >> /data/overlay.txt
echo "$ABCDESKTOP_PROVIDERNAME" >> /data/overlay.txt
echo "$ABCDESKTOP_USERID" >> /data/overlay.txt

log "/data/overlay.txt"
cat /data/overlay.txt

# .Xauthority
if [ ! -f ~/.Xauthority ]; then
	log "~/.Xauthority does not exist"
	# create a MIT-MAGIC-COOKIE-1 entry in .Xauthority
	if [ ! -z "$XAUTH_KEY" ]; then
        	log "xauth add $DISPLAY MIT-MAGIC-COOKIE-1 $XAUTH_KEY"
        	xauth add $DISPLAY MIT-MAGIC-COOKIE-1 $XAUTH_KEY 2>&1
		log "xauth add done exitcode=$?"
	fi
else
	log "~/.Xauthority exists"
fi


/usr/local/bin/overlay /data/overlay.txt -f Arial -d 0 -o CENTER -s 100 -t 4 -o CENTER
