#!/system/bin/sh
# DJS Config Tool
# Copyright (c) 2019, VR25 (xda-developers.com)
# License: GPLv3+


set -euo pipefail
trap 'e=$?; echo; exit $e' EXIT
config=/data/media/0/djs/djs.conf

if [[ $PATH != */busybox* ]]; then
  if [ -d /sbin/.magisk/busybox ]; then
    PATH=/sbin/.magisk/busybox:$PATH
  elif [ -d /sbin/.core/busybox ]; then
    PATH=/sbin/.core/busybox:$PATH
  fi
fi

if [ -f $config ]; then

  case ${1:-} in
    -a|--append)
      shift
      echo -e "$*" >> $config
    ;;
    -d|--delete)
      shift
      verCodeBkp=$(grep '^versionCode=' $config)
      sed -i "/$*/d" $config
      grep -q '^versionCode=' $config || echo $verCodeBkp >> $config
    ;;
    -e|--edit)
      shift
      $@ $config 2>/dev/null || vim $config 2>/dev/null \
        || vi $config 2>/dev/null || nano $config 2>/dev/null \
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

-a|--append "LINE"
  e.g., djsc -a 2200 reboot -p

-d|--delete "PATTERN" (all matching lines)
  e.g., djsc --delete 2200

-e|--edit EDITOR OPTS (fallback: vim|vi|nano)
  e.g., djs-config --edit nano -l

-l|--list "PATTERN" (default ".", meaning "all lines")
  e.g., djsc -l "^boot"
CAT
    ;;
  esac

else
  (/sbin/.djs/djs/djsd.sh &) &
  sleep 2
  $0 $@
fi
exit $?
