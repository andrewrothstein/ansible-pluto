#!/usr/bin/env bash
set -e
DIR=~/Downloads
MIRROR=https://github.com/FairwindsOps/pluto/releases/download
APP=pluto


# https://github.com/FairwindsOps/pluto/releases/download/v5.4.0/checksums.txt
# https://github.com/FairwindsOps/pluto/releases/download/v5.4.0/pluto_5.4.0_linux_amd64.tar.gz

dl() {
    local ver=$1
    local lchecksums=$2
    local os=$3
    local arch=$4
    local archive_type=${5:-tar.gz}
    local platform="${os}_${arch}"
    local file="${APP}_${ver}_${platform}.${archive_type}"
    local url=$MIRROR/v$ver/$file
    local sum
    sum=$(awk -v f="$file" '$2 == f || $2 == "*" f {print $1}' "$lchecksums")
    if ! printf '%s' "$sum" | grep -Eq '^[0-9a-f]{64}$'; then
        echo "no valid checksum for $file in $lchecksums" >&2
        exit 1
    fi
    printf "    # %s\n" "$url"
    printf "    %s: sha256:%s\n" "$platform" "$sum"
}

dl_ver() {
    local ver=$1
    local url="${MIRROR}/v$ver/checksums.txt"
    local lchecksums="${DIR}/${APP}_${ver}_checksums.txt"
    if [ ! -e $lchecksums ];
    then
        curl -fsSL --proto '=https' --tlsv1.2 -o "$lchecksums" "$url"
    fi

    printf "  # %s\n" "$url"
    printf "  '%s':\n" "$ver"

    dl "$ver" "$lchecksums" darwin amd64
    dl "$ver" "$lchecksums" darwin arm64
    dl "$ver" "$lchecksums" linux amd64
    dl "$ver" "$lchecksums" linux arm64
    dl "$ver" "$lchecksums" linux armv6
    dl "$ver" "$lchecksums" linux armv7
    dl "$ver" "$lchecksums" windows amd64
    dl "$ver" "$lchecksums" windows arm64
}

for v in "${@:-5.24.5}"; do
    dl_ver "$v"
done
