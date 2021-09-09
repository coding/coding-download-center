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
fi

package_name=$(awk '{print $1}' /tmp/index-body.md)
echo "check if package name have version number"
for i in $package_name; do
    expr "$i" : ".*\.[0-9]\+\." > /dev/null && echo "[ERROR] $i : package name should not have version!" && exit 2
done

## lint markdown
# TODO
