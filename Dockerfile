FROM ubuntu:16.04
MAINTAINER Marco A. Harrendorf <marco+github@harrendorf.net>

VOLUME ["/data"]

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install  software-properties-common python-software-properties \
    wget \
    apache2 \
    mysql-server \
    php5 \
    php5-gd \
    libapache2-mod-php5 \
    usbutils \
    vlc \
    libvlc-dev \
    libvlccore-dev  \
    ffmpeg && \
    service apache2 restart && \
    service mysql restart 

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \    
    add-apt-repository -y ppa:iconnor/zoneminder && \
    apt-get update && \
    apt-get upgrade && \
    apt-get install -y zoneminder &&\
    apt-get dist-upgrade

RUN adduser www-data video

ADD plugins/cambozola.jar /usr/share/zoneminder/www/cambozola.jar



    
ADD https://downloads.sourceforge.net/project/twiki/TWiki%20for%20all%20Platforms/TWiki-6.0.2/TWiki-6.0.2.tgz ./TWiki-6.0.2.tgz
RUN mkdir -p /var/www && tar xfv TWiki-6.0.2.tgz -C /var/www && rm TWiki-6.0.2.tgz

ADD perl/cpanfile /tmp/cpanfile

RUN cd /tmp && cpanm -l /var/www/twiki/lib/CPAN --installdeps /tmp/ && rm -rf /.cpanm  /tmp/cpanfile /var/www/twiki/lib/CPAN/man

ADD configs/vhost.conf /etc/apache2/sites-available/twiki.conf
ADD configs/LocalLib.cfg  /var/www/twiki/bin/LocalLib.cfg
ADD configs/LocalSite.cfg /var/www/twiki/lib/LocalSite.cfg

RUN a2enmod cgi expires && a2dissite '*' && a2ensite twiki.conf && chown -cR www-data: /var/www/twiki
RUN a2enmod ssl 
RUN a2enmod rewrite

ADD http://twiki.org/p/pub/Plugins/LdapContrib/LdapContrib.tgz /var/www/twiki/LdapContrib.tgz
RUN tar xfv /var/www/twiki/LdapContrib.tgz -C /var/www/twiki/

ADD bin/prepare-env.sh /prepare-env.sh
RUN chmod +x /prepare-env.sh

ADD bin/run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80 443





mysql -uroot < /usr/share/zoneminder/db/zm_create.sql && \
mysql -uroot -e "grant all on zm.* to 'zmuser'@localhost identified by 'zmpass';" && \
chmod 740 /etc/zm/zm.conf && \
chown root:www-data /etc/zm/zm.conf && \
a2enconf zoneminder && \
a2enmod rewrite && \
a2enmod cgi && \
chown -R www-data:www-data /usr/share/zoneminder/ && \
sed  -i 's/\;date.timezone =/date.timezone = \"America\/New_York\"/' /etc/php5/apache2/php.ini && \
service apache2 restart && \
service mysql restart && \
rm -r /etc/init.d/zoneminder && \
mkdir -p /etc/my_init.d

COPY zoneminder /etc/init.d/zoneminder
COPY firstrun.sh /etc/my_init.d/firstrun.sh


RUN chmod +x /etc/init.d/zoneminder && \
chmod +x /etc/my_init.d/firstrun.sh && \
service apache2 restart && \
update-rc.d -f apache2 remove && \
update-rc.d -f mysql remove && \
update-rc.d -f zoneminder remove
