FROM debian:stable-slim

# ENV variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="America/Los_Angeles"
ENV CUPSADMIN=admin
ENV CUPSPASSWORD=password
ENV CANONPPD=linux-UFRII-drv-v600-us-02.tar.gz


LABEL org.opencontainers.image.source="https://github.com/anujdatar/cups-docker"
LABEL org.opencontainers.image.description="CUPS Printer Server"
LABEL org.opencontainers.image.author="Anuj Datar <anuj.datar@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/anujdatar/cups-docker/blob/main/README.md"
LABEL org.opencontainers.image.licenses=MIT


# Install dependencies
RUN apt-get update -qq  && apt-get upgrade -qqy \
    && apt-get install -qqy \
    apt-utils \
    usbutils \
    cups \
    cups-filters \
    cups-bsd \
    printer-driver-all \
    printer-driver-cups-pdf \
    printer-driver-foo2zjs \
    foomatic-db-compressed-ppds \
    openprinting-ppds \
    hpijs-ppds \
    hp-ppd \
    hplip \
    libgtk-3-0 \
    avahi-daemon \
    inotify-tools \
    rsync \
    libcups2-dev \
    python3 \
    python3-dev \
    python3-pip \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*


# Install Canon PPD
RUN mkdir -p /tmp/CanonPPD \
    && wget --quiet -O /tmp/${CANONPPD} https://gdlp01.c-wss.com/gds/6/0100009236/20/${CANONPPD} \
    && tar -xvf /tmp/${CANONPPD} -C /tmp/CanonPPD \
    && ls -lRa /tmp/CanonPPD/linux-UFRII-drv-v600-us \
    && dpkg -i /tmp/CanonPPD/linux-UFRII-drv-v600-us/x64/Debian/cnrdrvcups-ufr2-us_6.00-1.02_amd64.deb \
    && ls -lRa /etc/cups/ppd \
    && rm -rf /tmp/${CANONPPD} /tmp/CanonPPD

#RUN pip install --break-system-packages pycups

EXPOSE 631
EXPOSE 5353/udp

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/IdleExitTimeout/#IdleExitTimeout/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

# back up cups configs in case used does not add their own
RUN cp -rp /etc/cups /etc/cups-bak

# We want a mount for these
VOLUME /config
VOLUME /services

# Add scripts
ADD root /
RUN chmod +x /*.sh

CMD ["/entrypoint.sh"]
