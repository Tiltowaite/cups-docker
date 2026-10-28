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
    locales \
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

RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create the target folder inside the image
RUN mkdir -p /drivers

# Copy the local drivers folder into the image
COPY ./drivers /drivers

# Install Canon UFRII driver

RUN dpkg -i /drivers/cnrdrvcups-ufr2-us_6.00-1.02_amd64.deb

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
