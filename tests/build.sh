#!/bin/sh
set -e
cd "$(dirname "$0")/.."
export TMP="$PWD/.Tools/tmp" TEMP="$PWD/.Tools/tmp"
./.Tools/bin/darklua.exe process src/init.luau dist/Proximity.luau -c .darklua.json
./.Tools/bin/darklua.exe process src/init.luau build/Proximity.dev.luau -c .darklua.dev.json
./.Tools/bin/lune.exe run tests/compile.luau
sh tests/make-ingame.sh > /dev/null
# keep every released version reachable at a fixed address
mkdir -p dist/v && cp dist/Proximity.luau "dist/v/$(cat VERSION | tr -d '\r\n').luau"
# the site's version picker reads this list
ls dist/v | sed 's/\.luau$//' | sort -t. -k1,1nr -k2,2nr -k3,3nr | awk 'BEGIN{printf "["} {printf "%s\"%s\"", (NR>1?",":""), $0} END{print "]"}' > site/assets/versions.json
