#!/bin/bash -e

OVFENV_FILE=/tmp/ovfenv.xml
grep "$1" "$OVFENV_FILE" | cut -d "\"" -f 4
