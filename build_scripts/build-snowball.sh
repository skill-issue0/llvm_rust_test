#!/bin/bash

if [[ "$ARCH" == "" ]] || [[ "$DIST" == "" ]] || [[ "$NAME" == "" ]]; then
    echo "Usage: env ARCH=... DIST=... NAME=... bash $0"
    exit 2
fi

set -x
set -e

# check out latest tag

label=snowball-"$NAME"-"$ARCH"

if [[ "$NAME" == "ce-specific" ]]; then
    export BUILD_FOR_CE=1
fi

bash build_scripts/release.sh