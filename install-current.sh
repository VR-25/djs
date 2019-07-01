#!/system/bin/sh
# From-source Installer/Upgrader
# Copyright (c) 2019, VR25 @xda-developers
# License: GPLv3+


# prepend Magisk's busybox to PATH
if [ -d /sbin/.magisk/busybox ]; then
  PATH=/sbin/.magisk/busybox:$PATH
elif [ -d /sbin/.core/busybox ]; then
  PATH=/sbin/.core/busybox:$PATH
fi

if ! which awk || ! which grep || ! which sed; then
  echo -e "\n(!) Install busybox or similar binary first\n"
  exit 1
fi > /dev/null

print() { sed -n "s|^$1=||p" ${2:-$srcDir/module.prop}; }

umask 022
set -euo pipefail

[ -f $PWD/${0##*/} ] && srcDir=$PWD || srcDir=${0%/*}
modId=$(print id)
name=$(print name)
author=$(print author)
version=$(print version)
versionCode=$(print versionCode)
installDir=/sbin/.magisk/modules
config=/data/media/0/$modId/${modId}.conf
configVer=$(print versionCode $config 2>/dev/null || :)

[ -d $installDir ] || installDir=/sbin/.core/img
[ -d $installDir ] || installDir=/data/adb
[ -d $installDir ] || { echo -e "\n(!) /data/adb/ not found\n"; exit 1; }


cat << CAT

$name $version
Copyright (c) 2017-2019, $author
License: GPLv3+

(i) Installing to $installDir/$modId/...
CAT

(pgrep -f /${modId}d.sh | xargs kill -9 2>/dev/null) || :

rm -rf $installDir/${modId:-_PLACEHOLDER_} 2>/dev/null
cp -R $srcDir/$modId/ $installDir/
installDir=$installDir/$modId
cp $srcDir/module.prop $installDir/

mkdir -p ${config%/*}/info
cp -f $srcDir/*.md ${config%/*}/info

if [ $installDir == /data/adb ]; then
  mv $installDir/service.sh $installDir/${modId}-init.sh
else
  ln $installDir/service.sh $installDir/post-fs-data.sh
  if [ $installDir == /sbin/.core/img ]; then
    sed -i s/\.magisk/\.core/ $installDir/${modId}.sh
    sed -i s/\.magisk/\.core/ $installDir/${modId}d.sh
  fi
fi
chmod 0755 $installDir/*.sh

# patch/upgrade config
if [ -f $config ]; then
  if [ ${configVer:-0} -lt 201906290 ] \
      || [ ${configVer:-0} -gt $(print versionCode $installDir/${modId}.conf) ]
    then
      { rm $config || :
      rm -rf ${config%/*}/dailyJobs || :; } 2>/dev/null
  fi
fi

chmod -R 0777 ${config%/*}
set +euo pipefail


cat << CAT
- Done

  LATEST CHANGES

CAT


println=false
cat ${config%/*}/info/README.md | while IFS= read -r line; do
  if $println; then
    echo "    $line"
  else
    echo "$line" | grep -q \($versionCode\) && println=true \
      && echo "    $line"
  fi
done


cat << CAT

  LINKS
    - Donate: paypal.me/vr25xda/
    - Facebook page: facebook.com/VR25-at-xda-developers-258150974794782/
    - Git repository: github.com/VR-25/$modId/
    - Telegram channel: t.me/vr25_xda/
    - Telegram profile: t.me/vr25xda/

(i) Rebooting is unnecessary.
- $modId daemon already started.

CAT


[ $installDir == /data/adb ] && echo -e "(i) Use init.d or an app to run $installDir/${modId}-init.sh on boot to initialize ${modId}.\n"

if [ -f $installDir/service.sh ]; then
  $installDir/service.sh --override
else
  $installDir/${modId}-init.sh --override
fi

exit 0
