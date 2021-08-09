#!/system/bin/sh
# DJS Config Tool
# Copyright (C) 2019-2021, VR25
# License: GPLv3+

exxit() {
  exitCode=$?
  echo
  exit $exitCode
}

set -eu
trap exxit EXIT
execDir=/data/adb/vr25/djs
config=${execDir}-data/config.txt

. $execDir/setup-busybox.sh

if [ -f $config ]; then

  case ${1:-} in
    -a|--append)
      shift
      echo -e "$*" >> $config
    ;;
    -d|--delete)
      shift
      verCodeBkp=$(grep '^versionCode=' $config)
      sed -i "\#$*#d" $config
      grep -q '^versionCode=' $config || echo $verCodeBkp >> $config
    ;;
    -e|--edit)
      shift
      $@ $config 2>/dev/null || nano -l $config 2>/dev/null \
        || vim $config 2>/dev/null || vi $config 2>/dev/null \
          || { echo $"\n(!) Unable to edit $config\n"; exit 1; }
    ;;
    -l|--list)
      shift
      echo
      grep -E "${*:-.}" $config | grep -v '^$'
    ;;
    *)
      cat << CAT

DJS Config Tool

Usage: djsc|djs-config OPTION ARGS

-a|--append 'LINE'
  e.g., djsc -a 2200 reboot -p

-d|--delete 'PATTERN' (all matching lines)
  e.g., djsc --delete 2200

-e|--edit EDITOR OPTS (fallback: nano -l|vim|vi)
  e.g., djs-config --edit vim

-l|--list 'PATTERN' (default ".", meaning "all lines")
  e.g., djsc -l '^boot'

Note: PATH starts with /data/adb/vr25/bin:/dev/.vr25/busybox.
This means schedules don't require additional busybox setup.
The first directory holds user executables.
CAT
    ;;
  esac

else
  $execDir/service.sh
  sleep 2
  $0 $@
fi
exit $?
