#!/system/bin/sh
# Daily Job Scheduler Initializer
# Copyright (C) 2019, VR25 @ xda-developers
# License: GPLv3+

# don't run more than once per boot session
([ -d /dev/djs ] && exit 0 || mkdir -p /dev/djs

# wait untill system has fully booted
until [[ -d /storage/emulated/0/djs || -d /storage/emulated/0/?ndroid ]] \
  && [[ "x$(getprop sys.boot_completed)" == x[1t]* ]] \
  && pm get-install-location 1>/dev/null 2>&1
do
  sleep 20
done

d=${0%/*}/system/bin
[ -d $d ] || d=${d%/*}/xbin
which djs 1>/dev/null || export PATH=$d:$PATH
unset d
djs boot 1>/dev/null 2>&1 &) &
