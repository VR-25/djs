#!/system/bin/sh
# Daily Job Scheduler Initializer
# Copyright (C) 2019, VR25 @ xda-developers
# License: GPL V3+

(# don't run more than once per boot session
[ -d /dev/djs ] && exit 0 || mkdir -p /dev/djs

# wait until /data is decrypted and system has fully booted
until [ -d /data/media/0/?ndroid ] \
  && echo "x$(getprop sys.boot_completed)" | grep -Eq '1|true' \
  && grep -q /storage/emulated /proc/mounts \
  && pm get-install-location >/dev/null 2>&1
do
  sleep 10
done

sh ${0%/*}/system/*bin/djs boot >/dev/null 2>&1 &) &
