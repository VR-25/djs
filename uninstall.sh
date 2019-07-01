#!/system/bin/sh
# remove leftovers

(modId=djs
rm -rf /data/adb/$modId 2>/dev/null
until [ -d /data/media/0/$modId ]; do sleep 60; done
rm -rf /data/media/0/$modId
exit 0 &) &
exit 0
