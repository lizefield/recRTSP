# recRTSP

recording RTSP stream

[Eufy IndoorCam 2K](https://www.ankerjapan.com/item/T8400.html)

## setup

install [openRTSP](http://www.live555.com/openRTSP/) (save RTSP stream from camera)

```
sudo apt install livemedia-utils
```

install ffmpeg (convert from RTSP to h264)

```
sudo apt install software-properties-common
sudo add-apt-repository ppa:jonathonf/ffmpeg-4
sudo apt update
sudo apt install ffmpeg
```

## manual execute

```
/home/user/recRTSP/bin/recording.sh 192.168.0.10 nas password rtsp://192.168.0.11/live
```

## crontab sample(every 5 minutes)

```
*/5 *   * * *   user  /home/user/recRTSP/bin/recording.sh 192.168.0.10 nas password rtsp://192.168.0.11/live >> /home/user/recRTSP/cron.log
```

