#!/bin/sh
# Checks to-lp.jq: every testdata/*.json must convert to its testdata/*.lp.
# Run inside the image so jq matches production:
#   docker run --rm -v "$PWD:/t" -w /t --entrypoint sh <image> test.sh
cd "$(dirname "$0")" || exit 1
rc=0
for json in testdata/*.json; do
  if jq -r --arg host test -f to-lp.jq "$json" | diff -u "${json%.json}.lp" -; then
    echo "ok   $json"
  else
    echo "FAIL $json"; rc=1
  fi
done
exit $rc
