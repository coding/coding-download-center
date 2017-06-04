#!/bin/bash

rm -rf qiniu
mkdir -p qiniu
wget -O /tmp/qshell.zip http://devtools.qiniu.com/qshell-v2.0.7.zip
unzip /tmp/qshell.zip -d ./qiniu/ || exit 2
cp ./qiniu/qshell_linux_amd64 ./qiniu/qshell
