#!/bin/bash
set -e

tail -n +3 index.md > /tmp/index-body.md
cd /tmp
cat index-body.md | sort > index-body-sorted.md 
diff index-body.md index-body-sorted.md

package_name=$(awk '{print $1}' index-body.md)
for i in $package_name;do
	[[ ! "$i" =~ \.[0-9]+\. ]] || ( echo "[ERROR] $i : package name should not have version!" && exit 2 )
done
