#!/bin/bash

# Don't use set -e because grep exits with status 1 if it finds zero
# matches, which would cause this script to exit prematurely. We could use
# set +e / set -e around the grepping, but there wouldn't be much point.

set -Euo pipefail

total=0

for file in "$@"
do
    if [ -s "$file" ]
    then
        lines=$(nbshow -s "$file" |
                    perl -pe 's/\e\[[0-9;]*[mGKH]//g' |
                    egrep -v '^(  source:|(markdown|code) cell |\s*%matplotlib|\s*(%%|#))' |
                    egrep -v '^\s*$' |
                    wc -l
             )
    else
        lines=$(echo -n '' | wc -l)
    fi
    echo -e "$lines\\t$file"
    total=$((total + lines))
done

printf "%8s\\tTOTAL\\n" $total
