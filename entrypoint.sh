#!/bin/sh

# Hacky solution to gain access to /proc/self/fd/1 and /proc/self/fd/2 which are owned by root
chmod 777 /dev/stdout /dev/stderr

if [ -n "$NEW_UID" ]; then
  usermod -u "$NEW_UID" movary
fi

if [ -n "$NEW_GID" ]; then
  groupmod -g "$NEW_GID" movary
fi

chown -R movary.movary /app /run /var/lib/nginx /var/log/nginx

exec su-exec movary "$@"
