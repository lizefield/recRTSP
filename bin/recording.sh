#!/bin/bash

# params
#  $1 nas ip address
#  $2 nas username
#  $3 nas password
#  $4444 rtsp source address [rtsp://192.168.0.10/live0]

NAS_IP=$1
NAS_USER=$2
NAS_PASS=$3
SOURCE_ADDRESS=$4

CURRENT_DIR=$(pwd)
echo $CURRENT_DIR

# ping check
ping -c 1 ${NAS_IP} >> /dev/null
if [ $? -ne 0 ]; then
  echo ${NAS_IP} is not exist
  exit 1
fi

# mount nfs
MOUNT_COUNT=$(mount|grep ${NAS_IP}|wc -l)
if [ $MOUNT_COUNT -eq 0 ]; then
  sudo mount -t cifs //${NAS_IP}/disk1 /mnt/nas -o username=${NAS_USER},password=${NAS_PASS}
fi
mount|grep ${NAS_IP}

# check process
OPEN_RTSP_PROCESS_COUNT=$(ps aux|grep [o]penRTSP|wc -l)
if [ $OPEN_RTSP_PROCESS_COUNT -eq 0 ]; then
  cd ${CURRENT_DIR}/data/rtsp
  openRTSP -D 15 -c -Q -F eufy- -P 300 -t ${SOURCE_ADDRESS} &
  cd ${CURRENT_DIR}
fi
ps aux|grep [o]penRTSP

# check rtsp files
OLD_FILES=$(find ${CURRENT_DIR}/data/rtsp -name 'eufy-*' -mmin +10)
echo "$OLD_FILES"
for FILE in $OLD_FILES
do
  echo $FILE
  TARGET_DATE=$(date '+%H:%M' -r ${FILE})
  DATE_PARAM=$(date '+%Y%m%d%H%M' -r ${FILE})
  echo $TARGET_DATE
  TARGET_FILES=$(ls -ld ${CURRENT_DIR}/data/rtsp/*|grep ${TARGET_DATE})
  echo "$TARGET_FILES"
  TARGET_FILES_COUNT=$(ls -ld ${CURRENT_DIR}/data/rtsp/*|grep ${TARGET_DATE}|wc -l)
  echo $TARGET_FILES_COUNT
  if [ $TARGET_FILES_COUNT -eq 2 ]; then
    echo converting...
    # create params
    TARGET_PARAMS=""
    for TARGET_FILE in $TARGET_FILES
    do
      if [[ $TARGET_FILE == *"eufy-"* ]]; then
        TARGET_PARAMS="${TARGET_PARAMS} -i ${TARGET_FILE}"
      fi
    done
    echo $TARGET_PARAMS
    echo $DATE_PARAM
    # convert
    ffmpeg -f h264 ${TARGET_PARAMS} -vcodec copy ${CURRENT_DIR}/data/h264/eufy-garage-${DATE_PARAM}.mp4
    # delete rtsp files
    for DELETE_FILE in $TARGET_FILES
    do
      if [[ $DELETE_FILE == *"eufy-"* ]]; then
        rm -f ${DELETE_FILE}
      fi
    done
    # backup to nas
    sudo cp ${CURRENT_DIR}/data/h264/eufy-garage-${DATE_PARAM}.mp4 /mnt/nas/security/cam/garage/
    rm -f ${CURRENT_DIR}/data/h264/eufy-garage-${DATE_PARAM}.mp4
    break
  else
    for DELETE_FILE in $TARGET_FILES
    do
      if [[ $DELETE_FILE == *"eufy-"* ]]; then
        rm -f ${DELETE_FILE}
      fi
    done
  fi
done

exit 0

