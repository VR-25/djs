#!/system/bin/sh
# Daily Job Scheduler Daemon
# Copyright (C) 2019-2021, VR25
# License: GPLv3+


exec > /dev/null 2>&1

set -u
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
if [ ! -f $tmpDir/boot.sh ]; then
  echo "#!/system/bin/sh" > $tmpDir/boot.sh
  grep '^boot | : --boot' $config | sed 's/^.... //' >> $tmpDir/boot.sh
  echo 'exit $?' >> $tmpDir/boot.sh
  chmod u+x $tmpDir/boot.sh
  start-stop-daemon -bx $tmpDir/boot.sh -S --
  grep -q '^boot .* : --delete' $config && sed -i '/^boot .* : --delete/d' $config
fi

# HH:MM schedules
while :; do
  time=$(date +%H%M)
  echo "#!/system/bin/sh" > $tmpDir/${time}.sh
  if grep "^$time " $config | sed 's/^.... //' >> $tmpDir/${time}.sh; then
    echo 'rm $0' >> $tmpDir/${time}.sh
    echo 'exit $?' >> $tmpDir/${time}.sh
    chmod u+x $tmpDir/${time}.sh
    grep -q ' : --delete' $tmpDir/${time}.sh && sed -i "/^$time .* : --delete/d" $config
    start-stop-daemon -bx $tmpDir/${time}.sh -S --
  fi
  sleep 40
  while [ $(date +%H%M) -eq $time ]; do
    sleep 10
  done
done

exit $?
