#!/system/bin/sh
# DJS Config Tool
# Copyright (c) 2019, VR25 (xda-developers.com)
# License: GPLv3+

exxit() {
  local exitCode=$?
  echo
  # config backup
  if [ -d /data/media/0/?ndroid ]; then
    [ /data/media/0/.acc-config-backup.txt -nt $config ] \
      || cp $config /data/media/0/.acc-config-backup.txt 2>/dev/null || :
  fi
  exit $exitCode
}

set -euo pipefail
trap exxit EXIT
config=/data/adb/djs-data/config.txt

. /dev/.djs/djs/busybox.sh

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
CAT
    ;;
  esac

else
  (/dev/.djs/djs/djsd.sh &) &
  sleep 2
  $0 $@
fi
exit $?
