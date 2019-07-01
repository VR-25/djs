#!/system/bin/sh
# Daily Job Scheduler Daemon
# Copyright (c) 2019, VR25 (xda-developers.com)
# License: GPLv3+


exec > /dev/null 2>&1

set -u
IFS=$'\t\n'
rootPath=/sbin/.djs
config=/data/media/0/djs/djs.conf
getv() { grep "^$1 " $config 2>/dev/null; }

if [[ $PATH != */busybox* ]]; then
  if [ -d /sbin/.magisk/busybox ]; then
    PATH=/sbin/.magisk/busybox:$PATH
  elif [ -d /sbin/.core/busybox ]; then
    PATH=/sbin/.core/busybox:$PATH
  fi
fi

pgrep -f /djsd.sh | sed s/$$// | xargs kill -9 2>/dev/null

# wait for data decryption
until [ -d /data/media/0/?ndroid ]; do slee 2; done

if [ ! -f $config ]; then
  mkdir -p ${config%/*}
  cp $rootPath/djs/djs.conf $config
  chmod -R 0777 ${config%/*}
fi

# boot schedules
for schedule in $(getv boot); do
  if ! grep -q "$schedule" $rootPath/boot 2>/dev/null; then
    echo "$schedule" >> $rootPath/boot
    (unset IFS; set +u; eval "$(echo "$schedule" | sed 's|^.... ||')" &) &
  fi
done

while :; do
  # HH:MM schedules
  for schedule in $(getv '[0-2].[0-5][0-9]'); do
    if [ $(date +%H%M) -eq $(echo "$schedule" | grep -o '^....') ]; then
      if ! grep -q "$schedule" $rootPath/HH:MM 2>/dev/null; then
        echo "$schedule" >> $rootPath/HH:MM
        (unset IFS; set +u; eval "$(echo "$schedule" | sed 's|^.... ||')" &) &
        (sleep 60; sed -i "\|$schedule|d" $rootPath/HH:MM &) &
        sleep 1
      fi
    fi
  done
  sleep 20
done

exit $?
