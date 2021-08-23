#!/system/bin/sh
# Daily Job Scheduler Daemon
# Copyright (C) 2019-2021, VR25
# License: GPLv3+

tmpDir=/dev/.vr25/djs
log=$tmpDir/djsd.log
execDir=/data/adb/vr25/djs
config=${execDir}-data/config.txt
getv() { grep -E "$1" $config 2>/dev/null; }

# verbose
[ -z "$LINENO" ] || export PS4='$LINENO: '
echo "###$(date)###" >> $log
echo "versionCode=$(sed -n s/versionCode=//p $execDir/module.prop 2>/dev/null)" >> $log
exec >> $log 2>&1
set -x

[ -f $execDir/disable ] && exit 0
. $execDir/setup-busybox.sh
pgrep -f /djs.sh | sed s/$$// | xargs kill -9 2>/dev/null
mkdir -p $tmpDir

if [ ! -f $config ]; then
  mkdir -p ${config%/*}
  cat $execDir/default-config.txt > $config
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
if [ ! -f $tmpDir/djsd-boot.sh ]; then
  echo "#!/system/bin/sh" > $tmpDir/djsd-boot.sh
  grep '^boot | : --boot' $config | sed 's/^.... //' >> $tmpDir/djsd-boot.sh
  echo 'exit $?' >> $tmpDir/djsd-boot.sh
  chmod u+x $tmpDir/djsd-boot.sh
  start-stop-daemon -bx $tmpDir/djsd-boot.sh -S --
  grep -q '^boot .* : --delete' $config && sed -i '/^boot .* : --delete/d' $config
fi

# HH:MM schedules
while :; do
  time=$(date +%H%M)
  script=$tmpDir/djsd-${time}.sh
  if [ ! -f $script ] && grep -q "^$time " $config; then
    sed -n "s|^$time |#!/system/bin/sh\n|p" $config > $script
    echo 'rm $0; exit $?' >> $script
    chmod u+x $script
    grep -q ' : --delete' $script && sed -i "/^$time .* : --delete/d" $config
    start-stop-daemon -bx $script -S --
  fi
  while [ $(date +%H%M) -eq $time ]; do
    sleep 20
  done
  [ $(du -k $log | cut -f1) -ge 8 ] && : > $log
done

exit $?
