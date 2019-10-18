#!/system/bin/sh
# $id Installer/Upgrader
# Copyright (c) 2019, VR25 (xda-developers.com)
# License: GPLv3+

set +x
echo
id=djs
umask 077

# log
mkdir -p /data/adb/${id}-data/logs
exec 2>/data/adb/${id}-data/logs/install.log
set -x

trap 'e=$?; echo; exit $e' EXIT

# set up busybox
if [ -d /sbin/.magisk/busybox ]; then
  [[ $PATH == /sbin/.magisk/busybox* ]] || PATH=/sbin/.magisk/busybox:$PATH
elif [ -d /sbin/.core/busybox ]; then
  [[ $PATH == /sbin/.core/busybox* ]] || PATH=/sbin/.core/busybox:$PATH
else
  [[ $PATH == /dev/.busybox* ]] || PATH=/dev/.busybox:$PATH
  if ! mkdir -m 700 /dev/.busybox 2>/dev/null; then
    if [ -x /data/adb/magisk/busybox ]; then
      /data/adb/magisk/busybox --install -s /dev/.busybox
    elif which busybox > /dev/null; then
      busybox --install -s /dev/.busybox
    else
      echo "(!) Install busybox binary first"
      exit 3
    fi
  fi
fi

# root check
if [ $(id -u) -ne 0 ]; then
  echo "(!) $0 must run as root (su)"
  exit 4
fi

print() { sed -n "s|^$1=||p" ${2:-$srcDir/module.prop}; }

set_perms() {
  local owner=${2:-0} perms=0600 target=$(readlink -f $1)
  if echo $target | grep -q '.*\.sh$' || [ -d $target ]; then perms=0700; fi
  chmod $perms $target
  chown $owner:$owner $target
  restorecon $target > /dev/null 2>&1 || :
}

set_perms_recursive() {
  local owner=${2:-0} target=""
  find $1 2>/dev/null | while read target; do set_perms $target $owner; done
}

set -euo pipefail

# set source code directory
[ -f $PWD/${0##*/} ] && srcDir=$PWD || srcDir=${0%/*}

# unzip flashable zip if source code is unavailable
if [ ! -f $srcDir/module.prop ]; then
  srcDir=/dev/.tmp
  rm -rf $srcDir 2>/dev/null || :
  mkdir $srcDir
  unzip -o ${ZIP:-${3:-}} -d $srcDir/ >&2
fi

name=$(print name)
author=$(print author)
version=$(print version)
versionCode=$(print versionCode)
installDir=${installDir0:-/data/data/mattecarra.accapp/files}
config=/data/media/0/$id/${id}.conf

# migrate/restore config
[ -f $config ] || mv ${config%/*}/config.txt $config 2>/dev/null || :
if [ -d ${config%/*} ] && [ ! -d /data/adb/${id}-data ]; then
  mv $config ${config%/*}/config.txt 2>/dev/null || :
  (cd /data/media/0; mv ${config%/*} ${id}-data
  tar -cf - ${id}-data | tar -xf - -C /data/adb)
  rm -rf ${id}-data
fi
config=/data/adb/${id}-data/config.txt
[ -f $config ] || cp /data/media/0/.${id}-config-backup.txt $config 2>/dev/null || :

configVer=$(print versionCode $config 2>/dev/null || :)

# check/set parent installation directory
[ -d $installDir ] || installDir=/sbin/.magisk/modules
[ -d $installDir ] || installDir=/sbin/.core/img
[ -d $installDir ] || installDir=/data/adb
[ -d $installDir ] || { echo "(!) /data/adb/ not found\n"; exit 1; }


cat << EOF
$name $version
Copyright (c) 2019, $author
License: GPLv3+

(i) Installing to $installDir/$id/...
EOF


(pkill -9 -f "/$id (-|--)|/${id}d.sh" ) || :

# install
rm -rf $(readlink -f /sbin/.$id/$id) $installDir/$id 2>/dev/null || :
cp -R $srcDir/$id/ $installDir/
installDir=$installDir/$id
[ ${installDir0:-x} == x ] && installDir0=/data/data/mattecarra.accapp/files/$id || installDir0=$installDir0/$id
cp $srcDir/module.prop $installDir/

mkdir -p ${config%/*}/info
cp -f $srcDir/*.md ${config%/*}/info

case $installDir in
  /data/adb/$id|$installDir0)
    mv $installDir/service.sh $installDir/${id}-init.sh;;
  *)
    ln $installDir/service.sh $installDir/post-fs-data.sh;;
esac

# patch/upgrade config
if [ -f $config ]; then
  if [ ${configVer:-0} -lt 201906290 ] \
      || [ ${configVer:-0} -gt $(print versionCode $installDir/default-config.txt) ]
    then
      rm $config
  else
    if [ $configVer -lt 201908180 ]; then
      echo "// This is a comment line" >> $config
      sed -i -e '/^versionCode=/s/=.*/=201908180/' -e 's|^#|//|' $config
    fi
  fi
fi

cp -f $srcDir/bin/${id}-uninstaller.zip /data/media/0/

# set perms
set_perms_recursive ${config%/*}
chmod 0666 /data/media/0/${id}-uninstaller.zip
case $installDir in
  /data/*/files/$id)
    pkg=${installDir%/files/$id}
    pkg=${pkg##/data*/}
    owner=$(grep $pkg /data/system/packages.list | awk '{print $2}')
    set_perms_recursive ${installDir%/*} $owner
  ;;
  *)
    set_perms_recursive $installDir
  ;;
esac

set +euo pipefail


cat << EOF
- Done

  LATEST CHANGES

EOF


# print changelog
tail -n +$(grep -n \($versionCode\) ${config%/*}/info/README.md | cut -d: -f1) \
  ${config%/*}/info/README.md | sed 's/^/    /'


cat << EOF

  LINKS
    - Donate: paypal.me/vr25xda/
    - Facebook page: facebook.com/VR25-at-xda-developers-258150974794782/
    - Git repository: github.com/VR-25/$id/
    - Telegram channel: t.me/vr25_xda/
    - Telegram profile: t.me/vr25xda/

(i) Rebooting is unnecessary.
- $id can be used right now.
- $id daemon started.
EOF


[ $installDir == /data/adb ] && echo -e "\n(i) Use init.d or an app to run $installDir/${id}-init.sh on boot to initialize ${id}."

echo
trap - EXIT

# initialize $id
if grep -q /storage/emulated /proc/mounts; then
  if [ -f $installDir/service.sh ]; then
    $installDir/service.sh --override
  else
    $installDir/${id}-init.sh --override
  fi
fi

e=$?
[ $e -eq 0 ] || { echo; exit $e; }
exit 0
