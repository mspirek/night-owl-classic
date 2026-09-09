#!/bin/sh
set -eu

expected_manifest='fb1adb858ffbed415bb84206b0b53c615ab23f2699cc9ee475c449c2743690f3'
expected_theme='2f503a22fdc0f8abf88e5200135b928128152c7e071c924d69f892b5568a4ba9'

test -f manifest.json
test -f theme.css
test -f screenshot.png

actual_manifest=$(shasum -a 256 manifest.json | awk '{print $1}')
actual_theme=$(shasum -a 256 theme.css | awk '{print $1}')

test "$actual_manifest" = "$expected_manifest"
test "$actual_theme" = "$expected_theme"

python3 -m json.tool manifest.json >/dev/null
python3 -c 'import json; m=json.load(open("manifest.json")); assert m == {"name":"Night Owl Classic","version":"1.0.3","minAppVersion":"1.0.0","author":"Max Qian","authorUrl":"https://github.com/AstroAir"}'
python3 -c 'import struct; d=open("screenshot.png", "rb").read(24); assert d[:8] == b"\x89PNG\r\n\x1a\n"; assert struct.unpack(">II", d[16:24]) == (512, 288)'

if grep -Ein '@import|url[[:space:]]*\(|https?://|javascript:' theme.css; then
  printf '%s\n' 'Unexpected external or executable CSS reference found.' >&2
  exit 1
fi

printf '%s\n' 'Night Owl Classic 1.0.3 release verification passed.'
