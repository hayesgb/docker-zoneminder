#!/bin/bash
  
echo "Preparing data folder"
if [ ! -d /data/data ]; then
  echo "Preparing data folder"
  mkdir /data/data
  mkdir /data/data/events
  mkdir /data/data/images
  mkdir /data/data/temp
else
  echo "Using existing data directory"
  rm -r /usr/share/zoneminder/www/events
  rm -r /usr/share/zoneminder/www/images
  rm -r /usr/share/zoneminder/www/temp
fi
echo "Linking data directories ..."
ln -s /data/data/events /usr/share/zoneminder/www/events
ln -s /data/data/images /usr/share/zoneminder/www/images
ln -s /data/data/temp /usr/share/zoneminder/www/temp
  
echo "Preparing mysql folder"
if [ ! -d /data/mysql/mysql ]; then
  echo "Moving mysql to data folder"
  cp -p -R /var/lib/mysql /data/
  rm -r /data/mysql
  echo "Restarting mysql"
  service mysql restart  
  echo "Adding default Zoneminder database settings"
  mysql -uroot < /usr/share/zoneminder/db/zm_create.sql 
  mysql -uroot -e "grant all on zm.* to 'zmuser'@localhost identified by 'zmpass';" 
  echo "Adding improved Zoneminder database settings"
  mysql -uroot < /ZoneminderImprovedDefaults.sql
else
  echo "Using existing mysql database"
  rm -r /var/lib/mysql
fi  
ln -s /data/mysql /var/lib/mysql
  
echo "Preparing php.ini"
if [ ! -f /data/php.ini ]; then
  echo "Copying default php.ini and set time zone to Europe Berlin"
  mv  /etc/php/7.0/apache2/php.ini /data/php.ini
  sed  -i 's/\;date.timezone =/date.timezone = \"Europe\/Berlin\"/' /data/php.ini 
else
  echo "php.ini already exists"
fi
ln -s /data/php.ini /etc/php/7.0/apache2/php.ini

echo "Preparing perl5 folder"
if [ ! -d /data/perl5 ]; then
  echo "Moving perl5 folder to data folder"
  mkdir /data/perl5
  cp -R -p /usr/share/perl5/ZoneMinder /data/perl5/
else
  echo "Using existing perl5 data directory"
  rm -r /usr/share/perl5/ZoneMinder
fi
ln -s /data/perl5/ZoneMinder /usr/share/perl5/ZoneMinder

echo "Preparing SSL cert and key"
if [ -f /data/ssl-certs ] ; then
  echo "External ssl-certs directory exists"
else
  echo "Missing ssl-certs directory, creating one"
  mkdir /data/ssl-certs
fi
if [ -f /data/ssl-certs/zoneminder-key.pem ] ; then
  echo "External zoneminder-key.pem exists"
  rm -f /data/ssl-certs/zoneminder-key.pem.missing
else
  echo "Missing zoneminder-key.pem, create empty one"
  echo "Add zoneminder-key.pem key in this folder" > /data/ssl-certs/zoneminder-key.pem.missing
fi
if [ -f /data/ssl-certs/zoneminder-fullchain.pem ] ; then
  echo "External zoneminder-fullchain.pem exists"
  rm -f /data/ssl-certs/zoneminder-fullchain.pem.missing
else
  echo "Missing zoneminder-fullchain.pem, create empty one"
  mkdir -p /data/ssl-certs
  echo "Add zoneminder-fullchain.pem key in this folder" > /data/ssl-certs/zoneminder-fullchain.pem.missing
fi

echo "Preparing zm.conf"
if [ ! -f /data/zm.conf ]; then
  echo "Copying default zm.conf"
  mv  /etc/zm/zm.conf /data/zm.conf
else
  echo "zm.conf already exists"
  rm /etc/zm/zm.conf
fi
ln -s /data/zm.conf /etc/zm/zm.conf
  
echo "Fix folder permissions"
chmod -R go+rw /data
chown -R mysql:mysql /var/lib/mysql
chown -R www-data:www-data /data/data
chmod 740 /etc/zm/zm.conf 
chown root:www-data /etc/zm/zm.conf 
chown -R www-data:www-data /usr/share/zoneminder/ 

#fix memory issue
echo "increasing shared memory"
umount /dev/shm
mount -t tmpfs -o rw,nosuid,nodev,noexec,relatime,size=${MEM:-4096M} tmpfs /dev/shm

echo "Cleaning default apache web folder"
rm -rf /var/www/html/*
touch /var/www/html/index.html

echo "Restarting MySQL"
service mysql restart

echo "Enabling Zoneminder"
service zoneminder restart
