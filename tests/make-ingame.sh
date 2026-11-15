#!/bin/sh
# Builds build/ingame-<example>.luau: the local bundle inlined in place of the
# loadstring line, so an unpublished build can be tested in an executor.
set -e
mkdir -p build
for ex in examples/*.luau; do
	name=$(basename "$ex" .luau)
	{
		printf 'local Proximity = (function()\n'
		cat dist/Proximity.luau
		printf '\nend)()\n'
		grep -v 'loadstring(game:HttpGet("https://raw.githubusercontent.com/ProximityDevProject' "$ex"
	} > "build/ingame-$name.luau"
done
ls -la build
