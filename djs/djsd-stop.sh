#!/system/bin/sh
pgrep -f /djsd.sh | xargs kill -9 2>/dev/null
exit 0
