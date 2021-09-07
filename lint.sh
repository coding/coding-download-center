#!/bin/bash
set -e

tail -n +3 index.md > /tmp/index-body.md
cd /tmp
cat index-body.md | sort > index-body-sorted.md 
diff index-body.md index-body-sorted.md

for i in `awk '{print $1}' /tmp/index-body.md`
do
  [[ "$i" =~ ^[a-z0-9.-]+$ ]]  || ( echo “$i: Product names shall be all in lower case” && exit 250 )
done

