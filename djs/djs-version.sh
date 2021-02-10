#!/system/bin/sh
echo
sed -n 's/^versionCode=//p' /dev/.djs/djs/module.prop
echo
exit 0
