#!/bin/sh
set -e
cd "$(dirname "$0")/.."
export TMP="$PWD/.Tools/tmp" TEMP="$PWD/.Tools/tmp"
./.Tools/bin/darklua.exe process src/init.luau dist/Proximity.luau -c .darklua.json
./.Tools/bin/darklua.exe process src/init.luau build/Proximity.dev.luau -c .darklua.dev.json
./.Tools/bin/lune.exe run tests/compile.luau
sh tests/make-ingame.sh > /dev/null
