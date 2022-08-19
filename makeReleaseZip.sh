#!/bin/bash -e

npm install
npx lix download
npx lix use haxe 4.2.5

rm -f haxeium.zip
zip -9 -r -q haxeium.zip src haxelib.json hxformat.json checkstyle.json package.json README.md CHANGELOG.md LICENSE.md
