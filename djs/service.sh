#!/system/bin/sh
# Daily Job Scheduler Daemon (djsd) Initializer
# Copyright (c) 2019, VR25 (xda-developers)
# License: GPLv3+

set +x
id=djs
umask 077

# log
mkdir -p /data/adb/${id}-data/logs
exec > /data/adb/${id}-data/logs/init.log 2>&1
set -x

[ -f $PWD/${0##*/} ] && modPath=$PWD || modPath=${0%/*}
. $modPath/busybox.sh

# prepare working directory
([ -d /dev/.$id ] && [[ ${1:-x} != -*o* ]] && exit 0
#if ! mount -o remount,rw /sbin 2>/dev/null; then
#  cp -a /sbin /dev/.sbin
#  mount -o bind,rw /dev/.sbin /sbin
#  restorecon -R /sbin > /dev/null 2>&1
#fi
mkdir -p /dev/.$id
[ -h /dev/.$id/$id ] && rm /dev/.$id/$id \
  || rm -rf /dev/.$id/$id 2>/dev/null
[ ${MAGISK_VER_CODE:-18200} -gt 18100 ] \
  && ln -s $modPath /dev/.$id/$id \
  || cp -a $modPath /dev/.$id/$id
ln -fs /dev/.${id}/${id}/${id}d-start.sh /bin/${id}d
ln -fs /dev/.${id}/${id}/${id}d-status.sh /bin/${id}d,
ln -fs /dev/.${id}/${id}/${id}d-stop.sh /bin/${id}d.
ln -fs /dev/.${id}/${id}/${id}d-status.sh /bin/${id}d-status
ln -fs /dev/.${id}/${id}/${id}-version.sh /bin/${id}-version
ln -fs /dev/.${id}/${id}/${id}d-stop.sh /bin/${id}d-stop
ln -fs /dev/.${id}/${id}/${id}c.sh /bin/${id}c
ln -fs /dev/.${id}/${id}/${id}c.sh /bin/${id}-config

# fix termux's PATH
termuxSu=/data/data/com.termux/files/usr/bin/su
if [ -f $termuxSu ] && grep -q 'PATH=.*/bin/su' $termuxSu; then
  sed '\|PATH=|s|/bin/su|/bin|' $termuxSu > $termuxSu.tmp
  cat $termuxSu.tmp > $termuxSu
  rm $termuxSu.tmp
fi

# start ${id}d
#${0%/*}/${id}d.sh &) &
/dev/.djs/djs/${id}d.sh &) &

exit 0
