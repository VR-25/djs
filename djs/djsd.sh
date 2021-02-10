#!/system/bin/sh
# Daily Job Scheduler Daemon
# Copyright (c) 2019, VR25 (xda-developers.com)
# License: GPLv3+


exec > /dev/null 2>&1

set -u
IFS=$'\t\n'
rootPath=/dev/.djs
config=/data/adb/djs-data/config.txt
getv() { grep -E "$1" $config 2>/dev/null; }

. /dev/.djs/djs/busybox.sh

pgrep -f /djsd.sh | sed s/$$// | xargs kill -9 2>/dev/null

if [ ! -f $config ]; then
  mkdir -p ${config%/*}
  cp $rootPath/djs/default-config.txt $config
  chmod -R 0600 ${config%/*}
fi

# config backup
if [ -d /data/media/0/?ndroid ]; then
  [ /data/media/0/.djs-config-backup.txt -nt $config ] \
    || cp $config /data/media/0/.djs-config-backup.txt 2>/dev/null
fi

# boot schedules
for schedule in $(getv '^boot | : --boot'); do
  if ! grep -q "$schedule" $rootPath/boot 2>/dev/null; then
    echo "$schedule" >> $rootPath/boot
    (unset IFS; set +u; eval "$(echo "$schedule" | sed 's#^.... ##')" &) &
  fi
done

while :; do
  # HH:MM schedules
  for schedule in $(getv '^[0-2].[0-5][0-9]'); do
    if [ $(date +%H%M) -eq $(echo "$schedule" | grep -o '^....') ]; then
      if ! grep -q "$schedule" $rootPath/HH:MM 2>/dev/null; then
        echo "$schedule" >> $rootPath/HH:MM
        (unset IFS; set +u; eval "$(echo "$schedule" | sed 's#^.... ##')" &) &
        (sleep 60; sed -i "\#$schedule#d" $rootPath/HH:MM &) &
        echo "$schedule" | grep -q ' : --delete' && sed -i "\#$schedule#d" $config
        sleep 1
      fi
    fi
  done
  sleep 20
done

exit $?
