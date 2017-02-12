# Zoneminder 1.29
A Dockerized Zoneminder
* Version 1.30
* Following features are enabled by default
  * MySQL MariaDB included
  * FFMPEG
  * Cambozola

## USAGE
All Data will be stored under `/data`. You should attach some
external storage there ` -v /mnt/twiki:/data`.

## Web GUI
* The web gui will be available at http://serverip:port/zm

## Important
* On first start, open zoneminder settings, go to the paths tab and enter the following for PATH_ZMS: ```/zm/cgi-bin/nph-zms```

## Change timezone
* The default timezone for php is set as America/New_York.
* If you would like to change the timezone, edit the php.ini in the config folder / data container.
* Here's a list of available timezone options: http://php.net/manual/en/timezones.php


## Activate FFMPEG and Cambozola plugin
* This container includes ffmpeg and cambozola but they need to be enabled in the settings. 
* In the WebUI, click on Options in the top right corner and go to the Images tab
  * Click on the box next to OPT_Cambozola to enable
  * Click on the box next OPT_FFMPEG to enable ffmpeg
  * Enter the following for ffmpeg path: /usr/bin/ffmpeg
  * Enter the following for ffmpeg "output" options: -r 30 -vcodec libx264 -threads 2 -b 2000k -minrate 800k -maxrate 5000k (you can change these options to your liking)
  * Next to ffmpeg_formats, add mp4 (you can also add a star after mp4 and remove the star after avi to make mp4 the default format)
  * Hit save
* Now you should be able to add your cams and record in mp4 x264 format


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
This repository was forked from https://github.com/aptalca/docker-zoneminder/tree/v1.29 and then modified, so that a newer OS, Zoneminder version and so on will be used.

