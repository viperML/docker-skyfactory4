#!/bin/sh
set -eux -o pipefail
cd /var/lib/skyfactory4
if [[ ! -f eula.txt ]]; then
    sh Install.sh
    echo "eula=true" > eula.txt
fi
sh ServerStart.sh
