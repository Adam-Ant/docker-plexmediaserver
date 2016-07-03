FROM debian:jessie

# 1. Create plex user
# 2. Download and install Plex (non plexpass)
# 3. Create writable config directory in case the volume isn't mounted
# This gets the latest non-plexpass version
# Note: We created a dummy /bin/start to avoid install to fail due to upstart not being installed.
# We won't use upstart anyway.
RUN useradd --system -u 787 -M --shell /usr/sbin/nologin plex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ca-certificates \
        curl \
 && curl -L 'https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu' -o plexmediaserver.deb \
 && touch /bin/start \
 && chmod +x /bin/start \
 && dpkg -i plexmediaserver.deb \
 && rm -f plexmediaserver.deb \
 && rm -f /bin/start \
 && apt-get purge -y --auto-remove \
        curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /config \
 && chown plex:plex /config

VOLUME /config
VOLUME /media

EXPOSE 32400

# location of configuration
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR /config/plex

ENV PLEX_MEDIA_SERVER_HOME /usr/lib/plexmediaserver
ENV LD_LIBRARY_PATH /usr/lib/plexmediaserver
ENV TMPDIR /tmp

ADD entrypoint.sh /
RUN chmod +x entrypoint.sh

USER plex

WORKDIR /usr/lib/plexmediaserver
ENTRYPOINT ["/entrypoint.sh"]
CMD ./Plex\ Media\ Server
