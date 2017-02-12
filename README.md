# Docker-Zoneminder
A Dockerized Zoneminder
* Version 1.30
* Following features are enabled by default
  * MySQL MariaDB included
  * FFMPEG
  * Cambozola

## USAGE
All Data will be stored under `/data`. You should attach some
external storage there ` -v /mnt/twiki:/data`.

## Data container
* The data container is used to store the most important Zoneminder configurations in subfolders

| data subfolder |    description                                               |
|----------------|--------------------------------------------------------------|
| data/data      | Contains zoneminder data like events, images, temp           |
| data/mysql     | Contains MariaDB database files                              |
| data/perl5     | Maps to perl5/ZoneMinder and can contain custom perl scripts |
| data/php.ini   | Useful to easily change time zone settings                   |
| data/ssl-certs | Contains zoneminder-fullchain.pem and zoneminder-key.pem     |
| data/zm.conf   | Useful to easily change basic Zoneminder settings            |

* Note on boot2docker and shared folder: Forwarding MySQL configuration and data subfolder is currently not working in boot2docker via a shared folder. Thus, you should not make use of a shared folder. I learned it the hard way ;-).

## Web GUI
* The web gui will be available at http://serverip:port/zm


## Change timezone
* The default timezone for php is set as Europe/Berlin.
* If you would like to change the timezone, edit the php.ini in the config folder / data container.
* Here's a list of available timezone options: http://php.net/manual/en/timezones.php




## Example

### Build docker image
```bash
docker build --tag docker-zoneminder:1.30  github.com/mharrend/docker-zoneminder
```

### Start docker container from image
```bash
docker run --restart=always -dt --privileged=true -p 80:80 -p 443:443 -v /docker:/data:rw -v /etc/localtime:/etc/localtime:ro  docker-zoneminder/1.30
```


## Note: Forked
This repository was forked from https://github.com/aptalca/docker-zoneminder/tree/v1.29 and then modified, so that a newer OS, Zoneminder version, and so on will be used.

