#!/system/bin/sh
# remove leftovers

(until [ -d /data/media/0/djs ]; do sleep 20; done
rm -rf /data/media/0/djs &) &
exit 0
