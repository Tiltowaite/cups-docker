FROM debian:stable-slim

# ENV variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="America/Los_Angeles"
ENV CUPSADMIN=admin
ENV CUPSPASSWORD=password

LABEL org.opencontainers.image.description="CUPS Printer Server"


# Install dependencies
RUN apt-get update -qq  && apt-get upgrade -qqy \
    && apt-get install -qqy \
    usbutils \
    cups \
    cups-filters \
    cups-filters-core-drivers \
    cups-bsd \
    cups-backend-bjnp \
    libcupsimage2 \
    libjpeg62-turbo \
    libpng16-16 \
    printer-driver-cups-pdf \
    printer-driver-gutenprint \
    lsb-release \
    libgtk-3-0 \
    dbus \
    avahi-daemon \
    avahi-utils \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*


# Create the target folder inside the image
RUN mkdir -p /drivers

# Copy the local drivers folder into the image
COPY ./drivers /drivers


# Install Canon UFRII driver cleanly
RUN mkdir -p /tmp/canon \
  && tar -xzf /drivers/linux-UFRII-drv-v600-us-02.tar.gz \
       --strip-components=3 \
       -C /tmp/canon \
       linux-UFRII-drv-v600-us/x64/Debian/cnrdrvcups-ufr2-us_6.00-1.02_amd64.deb \
  && dpkg -i /tmp/canon/cnrdrvcups-ufr2-us_6.00-1.02_amd64.deb \
  && rm -rf /tmp/canon


RUN mkdir -p /tmp/canon \
    && tar -xzf /drivers/cnijfilter2-5.20-1-deb.tar.gz \
         --strip-components=2 \
         -C /tmp/canon \
         cnijfilter2-5.20-1-deb/packages/cnijfilter2_5.20-1_amd64.deb \
    && dpkg -i /tmp/canon/cnijfilter2_5.20-1_amd64.deb \
    && rm -rf /tmp/canon


#RUN pip install --break-system-packages pycups

EXPOSE 631
EXPOSE 5353/udp

COPY ./config/cups/cupsd.conf /etc/cups/cupsd.conf
COPY ./config/avahi/*.service /etc/avahi/services/

RUN chmod 644 /etc/avahi/services/*.service
RUN chmod 644 /etc/cups/cupsd.conf

# Add scripts
ADD root /
RUN chmod +x /*.sh

CMD ["/entrypoint.sh"]
