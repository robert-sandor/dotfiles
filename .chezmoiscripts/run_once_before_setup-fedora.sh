#!/usr/bin/env bash
set -eo pipefail

if [[ "$OSID" != "linux-fedora" ]]; then
  exit 0
fi

echo "OS: $OSID"
echo "Headless: $HEADLESS"

# packages + settings TBD, added incrementally
