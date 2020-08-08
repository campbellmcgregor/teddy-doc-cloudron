#!/bin/bash

echo "Starting"
set -eu
set -x
exec /usr/local/bin/gosu cloudron:cloudron /app/code/jetty/bin/jetty.sh run
echo "Started"