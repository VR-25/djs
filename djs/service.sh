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
([ -d /sbin/.$id ] && [[ ${1:-x} != -*o* ]] && exit 0
if ! mount -o remount,rw /sbin 2>/dev/null; then
  cp -a /sbin /dev/.sbin
  mount -o bind,rw /dev/.sbin /sbin
  restorecon -R /sbin > /dev/null 2>&1
fi
mkdir -p /sbin/.$id
[ -h /sbin/.$id/$id ] && rm /sbin/.$id/$id \
  || rm -rf /sbin/.$id/$id 2>/dev/null
[ ${MAGISK_VER_CODE:-18200} -gt 18100 ] \
  && ln -s $modPath /sbin/.$id/$id \
  || cp -a $modPath /sbin/.$id/$id
ln -fs /sbin/.${id}/${id}/${id}d-start.sh /sbin/${id}d
ln -fs /sbin/.${id}/${id}/${id}d-status.sh /sbin/${id}d,
ln -fs /sbin/.${id}/${id}/${id}d-stop.sh /sbin/${id}d.
ln -fs /sbin/.${id}/${id}/${id}d-status.sh /sbin/${id}d-status
ln -fs /sbin/.${id}/${id}/${id}-version.sh /sbin/${id}-version
ln -fs /sbin/.${id}/${id}/${id}d-stop.sh /sbin/${id}d-stop
ln -fs /sbin/.${id}/${id}/${id}c.sh /sbin/${id}c
ln -fs /sbin/.${id}/${id}/${id}c.sh /sbin/${id}-config

# fix termux's PATH
termuxSu=/data/data/com.termux/files/usr/bin/su
if [ -f $termuxSu ] && grep -q 'PATH=.*/sbin/su' $termuxSu; then
  sed '\|PATH=|s|/sbin/su|/sbin|' $termuxSu > $termuxSu.tmp
  cat $termuxSu.tmp > $termuxSu
  rm $termuxSu.tmp
fi

# start ${id}d
${0%/*}/${id}d.sh &) &

exit 0
