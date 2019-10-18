#!/system/bin/sh
echo
sed -n 's/^versionCode=//p' /sbin/.djs/djs/module.prop
echo
exit 0
