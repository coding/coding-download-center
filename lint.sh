#!/bin/sh
set -e

if [ -z "$1" ]; then
    echo "no file"
    exit
fi

shell_files=$(echo "$@" | tr ' ' '\n' | { grep ".sh$" || true; })
if [ -n "$shell_files" ]; then
    echo "lint shell:"
    echo "$shell_files"
    echo "$shell_files" | xargs shellcheck
    echo "$shell_files" | xargs shfmt -d -i 4 -sr
else
    echo "no shell file"
fi

index_file=$(echo "$@" | tr ' ' '\n' | { grep "^index.md$" || true; })
if [ -n "$index_file" ]; then
    echo "lint index.md"
    echo "check package name sort by a-z"
    tail -n +3 index.md > /tmp/index-body.md
    cd /tmp
    sort index-body.md > index-body-sorted.md
    diff index-body.md index-body-sorted.md
    package_name=$(awk '{print $1}' index-body.md)
    for i in $package_name; do
        expr "$i" : "[a-z0-9\.-]\+$" > /dev/null || (echo "$i: Product names shall be all in lower case" && exit 250)
    done
fi
## lint markdown
# TODO
