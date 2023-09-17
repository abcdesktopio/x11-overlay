# Default release is 22.04
ARG BASE_IMAGE_RELEASE=22.04
# Default base image 
ARG BASE_IMAGE=ubuntu


# --- BEGIN builder ---
FROM $BASE_IMAGE:$BASE_IMAGE_RELEASE as builder
ENV DEBIAN_FRONTEND noninteractive

# install git for versionning
# get version.json file using mkversion.sh bash script
RUN apt-get update && apt-get install -y \
	git \
	build-essential \
	libx11-dev \
        libxfixes-dev \
        libxrandr-dev \
        libxft-dev \
        libfreetype-dev

# copy source code of x11-overlay
RUN mkdir -p /src/x11-overlay && \
    git clone https://github.com/abcdesktopio/x11-overlay.git /src/x11-overlay

RUN cd /src/x11-overlay && make
RUN cd /src/x11-overlay && ./bin/run_tests

# --- END OF builder ---

# --- start here
FROM $BASE_IMAGE:$BASE_IMAGE_RELEASE
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends debconf && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | /usr/bin/debconf-set-selections && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 
RUN apt-get update && apt-get install -y --no-install-recommends \
        xauth \
	libx11-6 \
        libxfixes3 \
        libxrandr2 \
        libxft2 \
        libfreetype6 \
	ttf-xfree86-nonfree \
	ttf-mscorefonts-installer && \
	rm -f /tmp/*.deb && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* 
RUN mkdir /data && chmod 666 /data
COPY --from=builder /src/x11-overlay/bin /usr/local/bin
COPY docker-entrypoint.sh /docker-entrypoint.sh
# change passwd shadow group gshadow
ENV ABCDESKTOP_LOCALACCOUNT_DIR "/etc/localaccount"
RUN mkdir -p $ABCDESKTOP_LOCALACCOUNT_DIR && \
    for f in passwd shadow group gshadow ; do if [ -f /etc/$f ] ; then  cp /etc/$f $ABCDESKTOP_LOCALACCOUNT_DIR ; rm -f /etc/$f; ln -s $ABCDESKTOP_LOCALACCOUNT_DIR/$f /etc/$f; fi; done
# set build date
RUN date > /etc/build.date
CMD  ["/docker-entrypoint.sh"]
