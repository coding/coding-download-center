#!/bin/bash
set -e

tail -n +3 index.md > /tmp/index-body.md
cd /tmp
cat index-body.md | sort > index-body-sorted.md 
diff index-body.md index-body-sorted.md
if [ $? -ne 0 ]; then
    echo "skip: software is not in alphabetical order"
fi