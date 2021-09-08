#!/bin/bash
set -e

tail -n +3 index.md > /tmp/index-body.md
cd /tmp
sort index-body.md > index-body-sorted.md
diff index-body.md index-body-sorted.md
