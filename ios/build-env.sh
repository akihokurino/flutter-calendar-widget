#!/bin/sh
# Copyright (c) 2021 Sho YAMASHITA

code=$(cat <<EOS

import Foundation

let Env: [String: String] = [

EOS
)

if [ $# -ne 2 ]; then
  echo "require 2 arguments." 1>&2
  echo "./buildEnv.sh /path/to/.env /output/path" 1>&2
  exit 1
fi

if [ -f "$1" ]; then
    while IFS='' read -r line || [[ -n "$line" ]]; do
        line="${line//[$'\r\n']}"
        trimline="${line//[$'\t\r\n ']}"
        if [ -n "$trimline" ]; then
            KEY="${line%%=*}"
            VALUE="${line##*=}"
            code=$(cat <<EOS
        $code
        "$KEY": "$VALUE",
EOS
)
        fi
    done < "$1"
fi

code=$(cat <<EOS
$code
]
EOS
)

echo "${code}" > "$2/Environment.swift"

exit 0