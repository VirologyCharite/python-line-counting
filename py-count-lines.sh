#!/bin/bash

# Don't use set -e because grep exits with status 1 if it finds zero
# matches, which would cause this script to exit prematurely. We could use
# set +e / set -e around the grepping, but there wouldn't be much point.

set -Euo pipefail

total=0

for file in "$@"
do
    lines=$(egrep -v '^\s*$|^\s*#' < "$file" | wc -l)
    echo -e "$lines\\t$file"
    total=$((total + lines))
done

printf "%8s\\tTOTAL\\n" $total
