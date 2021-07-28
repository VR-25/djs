#!/system/bin/sh
# Daily Job Scheduler Daemon
# Copyright (C) 2019-2021, VR25
# License: GPLv3+


exec > /dev/null 2>&1

set -u
IFS=$(printf '\t\n')
tmpDir=/dev/.vr25/djs
execDir=/data/adb/vr25/djs
config=${execDir}-data/config.txt
getv() { grep -E "$1" $config 2>/dev/null; }

[ -f $execDir/disable ] && exit 0
. $execDir/setup-busybox.sh
pgrep -f /djs.sh | sed s/$$// | xargs kill -9 2>/dev/null
mkdir -p $tmpDir

if [ ! -f $config ]; then
  mkdir -p ${config%/*}
  cp $execDir/default-config.txt $config
fi


# create symlinks for executables

ln -sf $execDir/djs-config.sh $tmpDir/djsc
ln -sf $execDir/djs-config.sh $tmpDir/djs-config

ln -sf $execDir/service.sh $tmpDir/djsd
ln -sf $execDir/service.sh $tmpDir/djs-daemon

ln -sf $execDir/djs-status.sh $tmpDir/djs,
ln -sf $execDir/djs-status.sh $tmpDir/djs-status

ln -sf $execDir/djs-stop.sh $tmpDir/djs.
ln -sf $execDir/djs-stop.sh $tmpDir/djs-stop

ln -sf $execDir/djs-version.sh $tmpDir/djsv
ln -sf $execDir/djs-version.sh $tmpDir/djs-version

if [ -d /sbin ]; then
  if grep -q '^tmpfs / ' /proc/mounts; then
    /system/bin/mount -o remount,rw / \
      || mount -o remount,rw /
  fi
  for h in $tmpDir/djs*; do
    ln -fs $h /sbin/ || break
  done
  ln -fs $tmpDir/djs. /sbin/djsd. \
    && ln -fs $tmpDir/djs, /sbin/djsd,
fi 2>/dev/null

#legacy

ln -sf $execDir/djs-config.sh /dev/djsc
ln -sf $execDir/djs-config.sh /dev/djs-config

ln -sf $execDir/service.sh /dev/djsd
ln -sf $execDir/service.sh /dev/djs-daemon

ln -sf $execDir/djs-status.sh /dev/djsd,
ln -sf $execDir/djs-status.sh /dev/djs-status

ln -sf $execDir/djs-stop.sh /dev/djsd.
ln -sf $execDir/djs-stop.sh /dev/djs-stop

ln -sf $execDir/djs-version.sh /dev/djsv
ln -sf $execDir/djs-version.sh /dev/djs-version


# boot schedules
for schedule in $(getv '^boot | : --boot'); do
  if ! grep -q "$schedule" $tmpDir/boot 2>/dev/null; then
    echo "$schedule" >> $tmpDir/boot
    (unset IFS; set +u; eval "$(echo "$schedule" | sed 's#^.... ##')" &) &
  fi
done

while :; do
  # HH:MM schedules
  for schedule in $(getv '^[0-2].[0-5][0-9]'); do
    if [ $(date +%H%M) -eq $(echo "$schedule" | grep -o '^.... ') ]; then
      if ! grep -q "$schedule" $tmpDir/HH:MM 2>/dev/null; then
        echo "$schedule" >> $tmpDir/HH:MM
        (unset IFS; set +u; eval "$(echo "$schedule" | sed 's#^.... ##')" &) &
        (sleep 60; sed -i "\#$schedule#d" $tmpDir/HH:MM &) &
        echo "$schedule" | grep -q ' : --delete' && sed -i "\#$schedule#d" $config
        sleep 1
      fi
    fi
  done
  sleep 20
done

exit $?
