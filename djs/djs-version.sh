#!/system/bin/sh
echo
sed -n 's/^versionCode=//p' /data/adb/vr25/djs/module.prop
echo
exit 0
