FROM s6on/debian

ENV DEBIAN_FRONTEND noninteractive

# update install
RUN apt-get update -y && apt-get upgrade -y && \
\
# install dependancies
    apt-get -y install apt-transport-https ca-certificates gnupg-agent curl xmlstarlet

# add plex gpg key
RUN mkdir /root/.gnupg/ && chmod 600 /root/.gnupg && \
   gpg --no-default-keyring --keyring /usr/share/keyrings/plex-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 97203C7B3ADCA79D && \
\
# add plex repo
   echo "deb [signed-by=/usr/share/keyrings/plex-archive-keyring.gpg] https://downloads.plex.tv/repo/deb public main" | tee /etc/apt/sources.list.d/plexmediaserver.list && \
\
# install pms
    apt-get update && \
    echo "y" | apt-get install -y --no-install-recommends plexmediaserver

# Add user
RUN useradd -U -d /config -s /bin/false plex && \
    usermod -G users plex && \
\
# Setup directories
    mkdir -p \
      /config \
      /transcode \
      /data

# Cleanup
RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

# add local files
COPY root/ /

EXPOSE 32400/tcp 3005/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp
VOLUME /config /transcode

ENV CHANGE_CONFIG_DIR_OWNERSHIP="true" \
    HOME="/config"

ENTRYPOINT ["/init"]
HEALTHCHECK --interval=5s --timeout=2s --retries=20 CMD /healthcheck.sh || exit 1

