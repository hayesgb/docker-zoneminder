FROM ubuntu:16.04
MAINTAINER Marco A. Harrendorf <marco+github@harrendorf.net>

VOLUME ["/data"]

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install  software-properties-common python-software-properties \
    wget \
    sudo \
    nano \
    apache2 \
    mysql-server \
    php \
    php-gd \
    libapache2-mod-php \
    usbutils \
    vlc \
    libvlc-dev \
    libvlccore-dev  \
    ffmpeg 
    
RUN service mysql restart 

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \    
    add-apt-repository -y ppa:iconnor/zoneminder && \
    apt-get update && \
    apt-get upgrade && \
    apt-get install -y zoneminder &&\
    apt-get dist-upgrade

RUN a2enconf zoneminder && \
    a2enmod cgi && \
    a2enmod rewrite

RUN adduser www-data video

ENV TZ=Europe/Berlin
RUN echo $TZ | tee /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

ADD plugins/cambozola.jar /usr/share/zoneminder/www/cambozola.jar
ADD configs/ZoneminderImprovedDefaults.sql /ZoneminderImprovedDefaults.sql

ADD bin/prepare-env.sh /prepare-env.sh
RUN chmod +x /prepare-env.sh

ADD bin/run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80 443
